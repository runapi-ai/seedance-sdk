# frozen_string_literal: true

module RunApi
  module Seedance
    # Seedance video generation API client.
    #
    # @example
    #   client = RunApi::Seedance::Client.new(api_key: "your-api-key")
    #   result = client.text_to_video.run(
    #     model: "seedance-2.0", prompt: "A cat walking through a garden"
    #   )
    class Client < RunApi::Core::Client
      # @return [Resources::TextToVideo] Video generation operations.
      attr_reader :text_to_video

      def initialize(api_key: nil, **options)
        super
        @text_to_video = Resources::TextToVideo.new(http)
      end
    end
  end
end
