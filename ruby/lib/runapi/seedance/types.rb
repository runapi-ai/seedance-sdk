# frozen_string_literal: true

module RunApi
  module Seedance
    # Type definitions and constants for Seedance video generation.
    #
    # Constants are grouped by model generation: 1.5, 2.0/2.0-fast, and V1.
    # Each generation has its own aspect ratio, resolution, and duration
    # constraints reflecting different rendering capabilities.
    module Types
      # V1-generation model identifiers: lite (low-cost), pro (high-quality), and pro-fast (speed-optimized).
      V1_MODELS = %w[seedance-v1-lite seedance-v1-pro seedance-v1-pro-fast].freeze
      # All supported model variants spanning 1.5, 2.0, and V1 generations.
      MODELS = (%w[seedance-1.5-pro seedance-2.0 seedance-2.0-fast] + V1_MODELS).freeze

      # Aspect ratios for seedance-1.5-pro; required with every request.
      ASPECT_RATIOS_1_5 = %w[1:1 4:3 3:4 16:9 9:16 21:9].freeze
      # Aspect ratios for 2.0/2.0-fast; includes "auto" for automatic selection.
      ASPECT_RATIOS_2 = [*ASPECT_RATIOS_1_5, "auto"].freeze
      # Aspect ratios for seedance-v1-lite; uses 9:21 (not 21:9) for tall portrait.
      ASPECT_RATIOS_V1_LITE = %w[1:1 4:3 3:4 16:9 9:16 9:21].freeze
      # Aspect ratios for seedance-v1-pro and seedance-v1-pro-fast.
      ASPECT_RATIOS_V1_PRO = %w[1:1 4:3 3:4 16:9 9:16 21:9].freeze

      # Output resolutions for seedance-1.5-pro.
      RESOLUTIONS_1_5 = %w[480p 720p 1080p].freeze
      # Output resolutions for seedance-2.0.
      RESOLUTIONS_SEEDANCE_2 = %w[480p 720p 1080p].freeze
      # Output resolutions for seedance-2.0-fast; capped at 720p for faster rendering.
      RESOLUTIONS_SEEDANCE_2_FAST = %w[480p 720p].freeze
      # Output resolutions for seedance-v1-lite and seedance-v1-pro.
      RESOLUTIONS_V1 = %w[480p 720p 1080p].freeze
      # Output resolutions for seedance-v1-pro-fast; minimum 720p.
      RESOLUTIONS_V1_PRO_FAST = %w[720p 1080p].freeze

      # Allowed duration values (seconds) for seedance-1.5-pro; discrete choices only.
      DURATIONS_1_5 = [4, 8, 12].freeze
      # Continuous duration range (seconds) for 2.0/2.0-fast; any integer 4-15 is accepted.
      DURATION_2_RANGE = (4..15)
      # Allowed duration values (seconds) for V1 models; 5 or 10.
      DURATIONS_V1 = [5, 10].freeze
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
