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
        def run(options: nil, **params)
          task = create(options: options, **params)
          poll_until_complete { get(task.id, options: options) }
        end

        # Create a video generation task.
        #
        # @param params [Hash] generation parameters
        # @return [RunApi::Seedance::Types::TextToVideoResponse] task creation result with id
        def create(options: nil, **params)
          params = compact_params(params)
          validate_params!(params)
          request(:post, ENDPOINT, body: params, options: options)
        end

        # Get generation status by task ID.
        #
        # @param id [String] task ID
        # @return [RunApi::Seedance::Types::TextToVideoResponse] current generation status
        def get(id, options: nil)
          request(:get, "#{ENDPOINT}/#{id}", options: options)
        end

        private

        def validate_params!(params)
          prompt = param(params, :prompt)
          raise Core::ValidationError, "prompt is required" unless prompt

          validate_contract!(CONTRACT["text-to-video"], params)

          model = param(params, :model)
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

          if has_image && field_present?(params, :aspect_ratio)
            raise Core::ValidationError, "aspect_ratio is not accepted in image-to-video mode; it is derived from the image"
          end

          if field_present?(params, :last_frame_image_url) && !(model == "seedance-v1-lite" && has_image)
            raise Core::ValidationError, "last_frame_image_url is only supported by seedance-v1-lite in image-to-video mode"
          end

          unsupported = %i[source_image_urls reference_image_urls reference_video_urls reference_audio_urls web_search generate_audio]
          reject_unsupported!(params, unsupported, model)

          reject_unsupported!(params, %i[lock_camera seed], model) if model == "seedance-v1-pro-fast"

          seed = param(params, :seed)
          if seed
            unless seed.is_a?(Integer) && Types::SEED_RANGE.cover?(seed)
              raise Core::ValidationError, "seed must be an integer between #{Types::SEED_RANGE.first} and #{Types::SEED_RANGE.last}"
            end
          end
        end

        def validate_1_5_pro!(params)
          if (value = param(params, :source_image_urls)).is_a?(Array) && value.size > 2
            raise Core::ValidationError, "source_image_urls accepts at most 2 images for seedance-1.5-pro"
          end

          unsupported = %i[first_frame_image_url last_frame_image_url reference_image_urls reference_video_urls reference_audio_urls web_search]
          reject_unsupported!(params, unsupported, "seedance-1.5-pro")
        end

        def validate_2!(params)
          unsupported = %i[source_image_urls lock_camera]
          reject_unsupported!(params, unsupported, param(params, :model))

          validate_mode_conflicts!(params)
          validate_seedance_2_4k_mode!(params)
        end

        def validate_mode_conflicts!(params)
          has_frame = Types::FRAME_FIELDS.any? { |f| field_present?(params, f) }
          has_reference = Types::REFERENCE_FIELDS.any? { |f| field_present?(params, f) }

          if has_frame && has_reference
            raise Core::ValidationError, "Cannot use frame mode and reference mode at the same time"
          end
        end

        def validate_seedance_2_4k_mode!(params)
          return unless param(params, :model) == "seedance-2.0"
          return unless param(params, :output_resolution) == "4k"

          unsupported = Types::FRAME_FIELDS + Types::REFERENCE_FIELDS
          field = unsupported.find { |candidate| field_present?(params, candidate) }
          return unless field

          raise Core::ValidationError, "#{field} is not allowed when model is seedance-2.0 and output_resolution is 4k"
        end

        def reject_unsupported!(params, fields, model)
          fields.each do |field|
            if field_present?(params, field)
              raise Core::ValidationError, "#{field} is not supported for #{model}"
            end
          end
        end
      end
    end
  end
end
