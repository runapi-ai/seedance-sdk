# frozen_string_literal: true

module RunApi
  module Seedance
    # Type definitions for Seedance video generation.
    module Types
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
