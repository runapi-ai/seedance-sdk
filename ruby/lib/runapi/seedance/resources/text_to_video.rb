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
          request(:post, ENDPOINT, body: params, options: options)
        end

        # Get generation status by task ID.
        #
        # @param id [String] task ID
        # @return [RunApi::Seedance::Types::TextToVideoResponse] current generation status
        def get(id, options: nil)
          request(:get, "#{ENDPOINT}/#{id}", options: options)
        end
      end
    end
  end
end
