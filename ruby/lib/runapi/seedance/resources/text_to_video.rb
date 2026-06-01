# frozen_string_literal: true

module RunApi
  module Seedance
    module Resources
      # Seedance video generation resource.
      # Generate videos from text prompts, images, or reference media.
      class TextToVideo
        include RunApi::Core::ResourceHelpers

        ENDPOINT = "/api/v1/seedance/text_to_video"

        RESPONSE_CLASS = Types::TextToVideoResponse
        COMPLETED_RESPONSE_CLASS = Types::CompletedTextToVideoResponse

        def initialize(http)
          @http = http
        end

        # Generate a video and wait until complete.
        #
        # @param params [Hash] generation parameters
        # @return [RunApi::Seedance::Types::CompletedTextToVideoResponse] completed generation with videos
        def run(**params)
          task = create(**params)
          poll_until_complete { get(task.id) }
        end

        # Create a video generation task.
        #
        # @param params [Hash] generation parameters
        # @return [RunApi::Seedance::Types::TextToVideoResponse] task creation result with id
        def create(**params)
          params = compact_params(params)
          validate_params!(params)
          request(:post, ENDPOINT, body: params)
        end

        # Get generation status by task ID.
        #
        # @param id [String] task ID
        # @return [RunApi::Seedance::Types::TextToVideoResponse] current generation status
        def get(id)
          request(:get, "#{ENDPOINT}/#{id}")
        end

        private

        def validate_params!(params)
          model = param(params, :model)
          raise Core::ValidationError, "model is required" unless model
          unless Types::MODELS.include?(model)
            raise Core::ValidationError, "Invalid model: #{model}. Must be one of: #{Types::MODELS.join(", ")}"
          end

          prompt = param(params, :prompt)
          raise Core::ValidationError, "prompt is required" unless prompt

          max_prompt = case model
          when "seedance-1.5-pro" then Types::PROMPT_MAX_LENGTH_1_5
          when *Types::V1_MODELS then Types::PROMPT_MAX_LENGTH_V1
          else Types::PROMPT_MAX_LENGTH_2
          end
          unless prompt.length.between?(Types::PROMPT_MIN_LENGTH, max_prompt)
            raise Core::ValidationError, "prompt length must be between #{Types::PROMPT_MIN_LENGTH} and #{max_prompt} characters"
          end

          case model
          when "seedance-1.5-pro" then validate_1_5_pro!(params)
          when *Types::V1_MODELS then validate_v1!(params)
          else validate_2!(params)
          end
        end

        def validate_v1!(params)
          model = param(params, :model)
          has_image = field_present?(params, :first_frame_image_url)

          if model == "seedance-v1-pro-fast" && !has_image
            raise Core::ValidationError, "seedance-v1-pro-fast requires first_frame_image_url"
          end

          if has_image && field_present?(params, :aspect_ratio)
            raise Core::ValidationError, "aspect_ratio is not accepted in image-to-video mode; it is derived from the image"
          end

          if field_present?(params, :last_frame_image_url) && !(model == "seedance-v1-lite" && has_image)
            raise Core::ValidationError, "last_frame_image_url is only supported by seedance-v1-lite in image-to-video mode"
          end

          unsupported = %i[source_image_urls reference_image_urls reference_video_urls reference_audio_urls web_search generate_audio]
          reject_unsupported!(params, unsupported, model)

          reject_unsupported!(params, %i[lock_camera seed], model) if model == "seedance-v1-pro-fast"

          duration_seconds = param(params, :duration_seconds)
          raise Core::ValidationError, "duration_seconds is required for Seedance V1; must be one of: #{Types::DURATIONS_V1.join(", ")}" unless duration_seconds
          unless Types::DURATIONS_V1.include?(duration_seconds)
            raise Core::ValidationError, "Invalid duration_seconds for #{model}: #{duration_seconds}. Must be one of: #{Types::DURATIONS_V1.join(", ")}"
          end

          unless has_image
            aspect_ratios = (model == "seedance-v1-lite") ? Types::ASPECT_RATIOS_V1_LITE : Types::ASPECT_RATIOS_V1_PRO
            validate_optional!(params, :aspect_ratio, aspect_ratios)
          end

          resolutions = (model == "seedance-v1-pro-fast") ? Types::RESOLUTIONS_V1_PRO_FAST : Types::RESOLUTIONS_V1
          validate_optional!(params, :output_resolution, resolutions)

          seed = param(params, :seed)
          if seed
            unless seed.is_a?(Integer) && Types::SEED_RANGE.cover?(seed)
              raise Core::ValidationError, "seed must be an integer between #{Types::SEED_RANGE.first} and #{Types::SEED_RANGE.last}"
            end
          end
        end

        def validate_1_5_pro!(params)
          validate_optional!(params, :aspect_ratio, Types::ASPECT_RATIOS_1_5)
          validate_optional!(params, :output_resolution, Types::RESOLUTIONS_1_5)

          duration_seconds = param(params, :duration_seconds)
          unless duration_seconds
            raise Core::ValidationError, "duration_seconds is required for seedance-1.5-pro; must be one of: #{Types::DURATIONS_1_5.join(", ")}"
          end

          if !Types::DURATIONS_1_5.include?(duration_seconds)
            raise Core::ValidationError, "Invalid duration_seconds for seedance-1.5-pro: #{duration_seconds}. Must be one of: #{Types::DURATIONS_1_5.join(", ")}"
          end

          if (value = param(params, :source_image_urls)).is_a?(Array) && value.size > 2
            raise Core::ValidationError, "source_image_urls accepts at most 2 images for seedance-1.5-pro"
          end

          unsupported = %i[first_frame_image_url last_frame_image_url reference_image_urls reference_video_urls reference_audio_urls web_search]
          reject_unsupported!(params, unsupported, "seedance-1.5-pro")
        end

        def validate_2!(params)
          validate_optional!(params, :aspect_ratio, Types::ASPECT_RATIOS_2)
          resolutions = (param(params, :model) == "seedance-2.0") ? Types::RESOLUTIONS_SEEDANCE_2 : Types::RESOLUTIONS_SEEDANCE_2_FAST
          validate_optional!(params, :output_resolution, resolutions)

          duration_seconds = param(params, :duration_seconds)
          if duration_seconds
            dur_int = duration_seconds.to_i
            unless Types::DURATION_2_RANGE.cover?(dur_int)
              raise Core::ValidationError, "Invalid duration_seconds for seedance-2.0: #{duration_seconds}. Must be an integer between 4 and 15"
            end
          end

          unsupported = %i[source_image_urls lock_camera]
          reject_unsupported!(params, unsupported, param(params, :model))

          validate_mode_conflicts!(params)
        end

        def validate_mode_conflicts!(params)
          has_frame = Types::FRAME_FIELDS.any? { |f| field_present?(params, f) }
          has_reference = Types::REFERENCE_FIELDS.any? { |f| field_present?(params, f) }

          if has_frame && has_reference
            raise Core::ValidationError, "Cannot use frame mode and reference mode at the same time"
          end
        end

        def reject_unsupported!(params, fields, model)
          fields.each do |field|
            if field_present?(params, field)
              raise Core::ValidationError, "#{field} is not supported for #{model}"
            end
          end
        end

        def field_present?(params, key)
          value = param(params, key)
          return false if value.nil?
          return value.any? if value.is_a?(Array)
          return !value.empty? if value.respond_to?(:empty?)

          true
        end
      end
    end
  end
end
