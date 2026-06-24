# frozen_string_literal: true

module RunApi
  module Seedance
    # Type definitions and constants for Seedance video generation.
    #
    # Per-model enum, range, and required constraints live in the generated
    # contract; the constants here back the bespoke checks the contract cannot
    # express (per-model prompt length and seed range).
    module Types
      # V1-generation model identifiers: lite (low-cost), pro (high-quality), and pro-fast (speed-optimized).
      V1_MODELS = %w[seedance-v1-lite seedance-v1-pro seedance-v1-pro-fast].freeze

      # Valid seed range; -1 requests a random seed.
      SEED_RANGE = (-1..2_147_483_647)

      # Minimum prompt length in characters, enforced across all models.
      PROMPT_MIN_LENGTH = 3
      # Maximum prompt length for seedance-1.5-pro.
      PROMPT_MAX_LENGTH_1_5 = 2500
      # Maximum prompt length for 2.0/2.0-fast (up to 20 000 characters).
      PROMPT_MAX_LENGTH_2 = 20000
      # Maximum prompt length for V1 models (up to 10 000 characters).
      PROMPT_MAX_LENGTH_V1 = 10000

      # Fields that specify first/last frame images for frame-conditioned generation.
      FRAME_FIELDS = %i[first_frame_image_url last_frame_image_url].freeze
      # Fields for reference-conditioned generation (images, videos, and audio).
      REFERENCE_FIELDS = %i[reference_image_urls reference_video_urls reference_audio_urls].freeze

      # A single generated video with its download URL.
      class Video < RunApi::Core::BaseModel
        optional :url, String
      end

      # Base async response returned immediately after task creation and during polling.
      class AsyncTaskResponse < RunApi::Core::TaskResponse
        required :id, String
        optional :status, String, enum: -> { RunApi::Core::TaskResponse::Status::ALL }
      end

      # Full response for a text-to-video task, including generated videos on completion.
      class TextToVideoResponse < AsyncTaskResponse
        optional :videos, [-> { Video }]
        optional :last_frame_image_url, String
        optional :error, String
      end

      # Narrowed response returned by `text_to_video.run()` once polling observes
      # `status: "completed"`. `videos` is required so consumers never have to
      # null-check it on a successful task. `last_frame_image_url` stays optional
      # because it may be absent.
      class CompletedTextToVideoResponse < TextToVideoResponse
        required :videos, [-> { Video }]
      end
    end
  end
end
