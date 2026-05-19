# frozen_string_literal: true

module RunApi
  module Seedance
    module Types
      V1_MODELS = %w[seedance-v1-lite seedance-v1-pro seedance-v1-pro-fast].freeze
      MODELS = (%w[seedance-1.5-pro seedance-2 seedance-2-fast] + V1_MODELS).freeze

      ASPECT_RATIOS_1_5 = %w[1:1 4:3 3:4 16:9 9:16 21:9].freeze
      ASPECT_RATIOS_2 = [ *ASPECT_RATIOS_1_5, "auto" ].freeze
      ASPECT_RATIOS_V1_LITE = %w[1:1 4:3 3:4 16:9 9:16 9:21].freeze
      ASPECT_RATIOS_V1_PRO = %w[1:1 4:3 3:4 16:9 9:16 21:9].freeze

      RESOLUTIONS_1_5 = %w[480p 720p 1080p].freeze
      RESOLUTIONS_SEEDANCE_2 = %w[480p 720p 1080p].freeze
      RESOLUTIONS_SEEDANCE_2_FAST = %w[480p 720p].freeze
      RESOLUTIONS_V1 = %w[480p 720p 1080p].freeze
      RESOLUTIONS_V1_PRO_FAST = %w[720p 1080p].freeze

      DURATIONS_1_5 = %w[4 8 12].freeze
      DURATION_2_RANGE = (4..15)
      DURATIONS_V1 = %w[5 10].freeze
      SEED_RANGE = (-1..2_147_483_647)

      PROMPT_MIN_LENGTH = 3
      PROMPT_MAX_LENGTH_1_5 = 2500
      PROMPT_MAX_LENGTH_2 = 20000
      PROMPT_MAX_LENGTH_V1 = 10000

      FRAME_FIELDS = %i[first_frame_url last_frame_url].freeze
      REFERENCE_FIELDS = %i[reference_image_urls reference_video_urls reference_audio_urls].freeze

      class Video < RunApi::Core::BaseModel
        optional :url, String
      end

      class AsyncTaskResponse < RunApi::Core::TaskResponse
        required :id, String
        optional :status, String, enum: -> { RunApi::Core::TaskResponse::Status::ALL }
      end

      class TextToVideoResponse < AsyncTaskResponse
        optional :videos, [ -> { Video } ]
        optional :last_frame_url, String
        optional :error, String
      end

      # Narrowed response returned by `text_to_video.run()` once polling observes
      # `status: "completed"`. `videos` is required so consumers never have to
      # null-check it on a successful task. `last_frame_url` stays optional
      # because it may be absent.
      class CompletedTextToVideoResponse < TextToVideoResponse
        required :videos, [ -> { Video } ]
      end
    end
  end
end
