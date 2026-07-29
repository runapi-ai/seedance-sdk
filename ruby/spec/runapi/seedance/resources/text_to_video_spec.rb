# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunApi::Seedance::Resources::TextToVideo do
  let(:http) { instance_double(RunApi::Core::HttpClient) }
  let(:text_to_video) { described_class.new(http) }
  let(:endpoint) { "/api/v1/seedance/text_to_video" }

  describe "#create (common validation)" do
    it "raises ValidationError when model is missing" do
      expect { text_to_video.create(prompt: "test") }
        .to raise_error(RunApi::Core::ValidationError, /model must be one of:/)
    end

    it "raises ValidationError for invalid model" do
      expect { text_to_video.create(model: "seedance-9000", prompt: "test") }
        .to raise_error(RunApi::Core::ValidationError, /model must be one of:/)
    end

    it "raises ValidationError when prompt is missing" do
      expect { text_to_video.create(model: "seedance-2.0", aspect_ratio: "16:9") }
        .to raise_error(RunApi::Core::ValidationError, /prompt is required/)
    end
  end

  describe "#create (seedance-1.5-pro)" do
    let(:base_params) do
      {model: "seedance-1.5-pro", prompt: "a calm lake", aspect_ratio: "16:9", duration_seconds: 8}
    end

    it "POSTs the happy path with source_image_urls and lock_camera" do
      params = base_params.merge(
        output_resolution: "720p",
        duration_seconds: 8,
        source_image_urls: ["https://cdn.runapi.ai/public/samples/input.png"],
        lock_camera: true,
        seed: 42
      )
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-15")

      result = text_to_video.create(**params)
      expect(result).to be_a(RunApi::Seedance::Types::TextToVideoResponse)
      expect(result.id).to eq("task-15")
    end

    it "raises ValidationError for invalid aspect_ratio" do
      expect { text_to_video.create(**base_params.merge(aspect_ratio: "adaptive")) }
        .to raise_error(RunApi::Core::ValidationError, /aspect_ratio must be one of:/)
    end

    it "raises ValidationError for invalid output_resolution" do
      expect { text_to_video.create(**base_params.merge(output_resolution: "480i")) }
        .to raise_error(RunApi::Core::ValidationError, /output_resolution must be one of:/)
    end

    it "raises ValidationError for out-of-range duration_seconds" do
      expect { text_to_video.create(**base_params.merge(duration_seconds: 13)) }
        .to raise_error(RunApi::Core::ValidationError, /duration_seconds must be between 4 and 12/)
    end

    it "raises ValidationError when duration_seconds is missing" do
      expect { text_to_video.create(**base_params.except(:duration_seconds)) }
        .to raise_error(RunApi::Core::ValidationError, /duration_seconds is required/)
    end

    it "rejects prompts longer than 2500 characters" do
      expect { text_to_video.create(**base_params.merge(prompt: "a" * 2501)) }
        .to raise_error(RunApi::Core::ValidationError, /prompt length must be between 3 and 2500 characters/)
    end

    it "rejects first_frame_image_url (frame mode is seedance-2.0 only)" do
      expect { text_to_video.create(**base_params.merge(first_frame_image_url: "https://cdn.runapi.ai/public/samples/result.png")) }
        .to raise_error(RunApi::Core::ValidationError, /first_frame_image_url is not allowed when model is seedance-1\.5-pro/)
    end

    it "rejects reference_image_urls (reference mode is seedance-2.0 only)" do
      expect { text_to_video.create(**base_params.merge(reference_image_urls: ["https://cdn.runapi.ai/public/samples/result.png"])) }
        .to raise_error(RunApi::Core::ValidationError, /reference_image_urls is not allowed when model is seedance-1\.5-pro/)
    end
  end

  describe "#create (seedance-2.x)" do
    it "POSTs the text-to-video happy path for seedance-2.0" do
      params = {
        model: "seedance-2.0",
        prompt: "a bustling market",
        aspect_ratio: "16:9",
        duration_seconds: 8,
        generate_audio: false
      }
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-2")

      text_to_video.create(**params)
    end

    it "accepts frame mode (first_frame_image_url + last_frame_image_url)" do
      params = {
        model: "seedance-2.0",
        prompt: "a sunrise transition",
        first_frame_image_url: "https://cdn.runapi.ai/public/samples/first-frame.jpg",
        last_frame_image_url: "https://cdn.runapi.ai/public/samples/last-frame.jpg"
      }
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-frame")

      text_to_video.create(**params)
    end

    it "accepts reference mode (reference_*)" do
      params = {
        model: "seedance-2.0-fast",
        prompt: "same style as the reference",
        reference_video_urls: ["https://cdn.runapi.ai/public/samples/reference.mp4"],
        reference_image_urls: ["https://cdn.runapi.ai/public/samples/reference.jpg"]
      }
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-ref")

      text_to_video.create(**params)
    end

    it "accepts seedance-2-mini reference mode" do
      params = {
        model: "seedance-2-mini",
        prompt: "compact cinematic motion",
        reference_video_urls: ["https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"],
        reference_audio_urls: ["https://cdn.runapi.ai/public/samples/music.mp3"],
        output_resolution: "720p",
        aspect_ratio: "auto",
        duration_seconds: 8,
        generate_audio: false
      }
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-mini")

      text_to_video.create(**params)
    end

    it "rejects frame mode combined with reference mode" do
      expect do
        text_to_video.create(
          model: "seedance-2.0",
          prompt: "conflicting modes",
          first_frame_image_url: "https://cdn.runapi.ai/public/samples/result.png",
          reference_image_urls: ["https://cdn.runapi.ai/public/samples/result-2.png"]
        )
      end.to raise_error(RunApi::Core::ValidationError, /Cannot use frame mode and reference mode at the same time/)
    end

    it "rejects source_image_urls (1.5-pro only field)" do
      expect do
        text_to_video.create(
          model: "seedance-2.0",
          prompt: "test",
          source_image_urls: ["https://cdn.runapi.ai/public/samples/result.png"]
        )
      end.to raise_error(RunApi::Core::ValidationError, /source_image_urls is not allowed when model is seedance-2.0/)
    end

    it "rejects lock_camera (1.5-pro only field)" do
      expect do
        text_to_video.create(
          model: "seedance-2.0-fast",
          prompt: "test",
          lock_camera: true
        )
      end.to raise_error(RunApi::Core::ValidationError, /lock_camera is not allowed when model is seedance-2.0-fast/)
    end

    it "raises ValidationError for out-of-range duration_seconds" do
      expect do
        text_to_video.create(model: "seedance-2.0", prompt: "test", duration_seconds: 20)
      end.to raise_error(RunApi::Core::ValidationError, /duration_seconds must be between 4 and 15/)
    end

    it "accepts auto aspect_ratio (2.x only)" do
      params = {model: "seedance-2.0", prompt: "test", aspect_ratio: "auto"}
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-auto")

      text_to_video.create(**params)
    end

    it "accepts 1080p output_resolution for seedance-2.0" do
      params = {model: "seedance-2.0", prompt: "test", output_resolution: "1080p"}
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-1080")

      text_to_video.create(**params)
    end

    it "accepts 4k output_resolution for seedance-2.0 text generation" do
      params = {model: "seedance-2.0", prompt: "test", output_resolution: "4k"}
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-4k")

      text_to_video.create(**params)
    end

    it "rejects 4k output_resolution with frame inputs for seedance-2.0" do
      expect do
        text_to_video.create(
          model: "seedance-2.0",
          prompt: "test",
          output_resolution: "4k",
          first_frame_image_url: "https://cdn.runapi.ai/public/samples/first-frame.jpg"
        )
      end.to raise_error(RunApi::Core::ValidationError, /first_frame_image_url is not allowed when model is seedance-2.0 and output_resolution is 4k/)
    end

    it "rejects 1080p output_resolution for seedance-2.0-fast" do
      expect do
        text_to_video.create(model: "seedance-2.0-fast", prompt: "test", output_resolution: "1080p")
      end.to raise_error(RunApi::Core::ValidationError, /output_resolution must be one of:/)
    end

    it "rejects 1080p output_resolution for seedance-2-mini" do
      expect do
        text_to_video.create(model: "seedance-2-mini", prompt: "test", output_resolution: "1080p")
      end.to raise_error(RunApi::Core::ValidationError, /output_resolution must be one of:/)
    end

    it "rejects prompts shorter than 3 characters" do
      expect do
        text_to_video.create(model: "seedance-2.0", prompt: "hi")
      end.to raise_error(RunApi::Core::ValidationError, /prompt length must be between 3 and 20000 characters/)
    end

    it "rejects prompts longer than 20000 characters" do
      expect do
        text_to_video.create(model: "seedance-2.0-fast", prompt: "a" * 20001)
      end.to raise_error(RunApi::Core::ValidationError, /prompt length must be between 3 and 20000 characters/)
    end
  end

  describe "#create (seedance-v1-*)" do
    it "rejects v1-pro-fast without first_frame_image_url" do
      expect do
        text_to_video.create(model: "seedance-v1-pro-fast", prompt: "test", output_resolution: "720p", duration_seconds: 5)
      end.to raise_error(RunApi::Core::ValidationError, /first_frame_image_url is required/)
    end

    it "POSTs v1-pro-fast with seed" do
      params = {
        model: "seedance-v1-pro-fast",
        prompt: "Animate quickly",
        first_frame_image_url: "https://cdn.runapi.ai/public/samples/result.png",
        output_resolution: "720p",
        duration_seconds: 5,
        seed: 42
      }
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-fast-seed")

      text_to_video.create(**params)
    end

    it "rejects aspect_ratio in image-to-video mode" do
      expect do
        text_to_video.create(
          model: "seedance-v1-pro",
          prompt: "test",
          first_frame_image_url: "https://cdn.runapi.ai/public/samples/result.png",
          aspect_ratio: "16:9",
          output_resolution: "720p",
          duration_seconds: 5
        )
      end.to raise_error(RunApi::Core::ValidationError, /aspect_ratio is not accepted in image-to-video mode/)
    end

    it "rejects last_frame_image_url on v1-pro" do
      expect do
        text_to_video.create(
          model: "seedance-v1-pro",
          prompt: "test",
          first_frame_image_url: "https://cdn.runapi.ai/public/samples/result.png",
          last_frame_image_url: "https://cdn.runapi.ai/public/samples/result-2.png",
          output_resolution: "720p",
          duration_seconds: 5
        )
      end.to raise_error(RunApi::Core::ValidationError, /last_frame_image_url is not allowed when model is seedance-v1-pro/)
    end

    it "rejects 480p on v1-pro-fast" do
      expect do
        text_to_video.create(
          model: "seedance-v1-pro-fast",
          prompt: "test",
          first_frame_image_url: "https://cdn.runapi.ai/public/samples/result.png",
          output_resolution: "480p",
          duration_seconds: 5
        )
      end.to raise_error(RunApi::Core::ValidationError, /output_resolution must be one of:/)
    end

    it "rejects duration_seconds not in v1 enum" do
      expect do
        text_to_video.create(
          model: "seedance-v1-pro",
          prompt: "test",
          aspect_ratio: "16:9",
          output_resolution: "720p",
          duration_seconds: 8
        )
      end.to raise_error(RunApi::Core::ValidationError, /duration_seconds must be one of: 5, 10/)
    end

    it "rejects seed out of range" do
      expect do
        text_to_video.create(
          model: "seedance-v1-pro",
          prompt: "test",
          aspect_ratio: "16:9",
          output_resolution: "720p",
          duration_seconds: 5,
          seed: -2
        )
      end.to raise_error(RunApi::Core::ValidationError, /seed must be an integer/)
    end

    it "rejects prompt longer than 10000 characters for v1" do
      expect do
        text_to_video.create(
          model: "seedance-v1-pro",
          prompt: "a" * 10001,
          aspect_ratio: "16:9",
          output_resolution: "720p",
          duration_seconds: 5
        )
      end.to raise_error(RunApi::Core::ValidationError, /prompt length must be between 3 and 10000 characters/)
    end
  end

  describe "#get" do
    it "GETs the correct endpoint" do
      expect(http).to receive(:request).with(:get, "#{endpoint}/task-1")
        .and_return("id" => "task-1", "status" => "completed", "model" => "seedance-2.0")

      result = text_to_video.get("task-1")
      expect(result).to be_a(RunApi::Seedance::Types::TextToVideoResponse)
      expect(result.status).to eq("completed")
      expect(result.model).to eq("seedance-2.0")
    end

    it "exposes videos and last_frame_image_url on completed response" do
      expect(http).to receive(:request).with(:get, "#{endpoint}/task-1")
        .and_return(
          "id" => "task-1",
          "status" => "completed",
          "model" => "seedance-2.0",
          "videos" => [{"url" => "https://cdn.runapi.ai/public/samples/source.mp4"}],
          "last_frame_image_url" => "https://cdn.runapi.ai/public/samples/last-frame.png"
        )

      result = text_to_video.get("task-1")
      expect(result.videos.size).to eq(1)
      expect(result.videos.first.url).to eq("https://cdn.runapi.ai/public/samples/source.mp4")
      expect(result.last_frame_image_url).to eq("https://cdn.runapi.ai/public/samples/last-frame.png")
    end

    it "exposes error on failed response" do
      expect(http).to receive(:request).with(:get, "#{endpoint}/task-1")
        .and_return(
          "id" => "task-1",
          "status" => "failed",
          "model" => "seedance-2.0-fast",
          "error" => "Generation failed upstream"
        )

      result = text_to_video.get("task-1")
      expect(result.status).to eq("failed")
      expect(result.error).to eq("Generation failed upstream")
    end
  end

  describe "#run" do
    it "creates then polls until complete" do
      create_params = {model: "seedance-2.0", prompt: "a cat"}
      expect(http).to receive(:request).with(:post, endpoint, body: create_params)
        .and_return("id" => "task-1")

      expect(http).to receive(:request).with(:get, "#{endpoint}/task-1")
        .and_return("id" => "task-1", "status" => "processing")
      expect(http).to receive(:request).with(:get, "#{endpoint}/task-1")
        .and_return(
          "id" => "task-1",
          "status" => "completed",
          "model" => "seedance-2.0",
          "videos" => [{"url" => "https://cdn.runapi.ai/public/samples/source.mp4"}]
        )

      allow(RunApi::Core::Polling).to receive(:sleep)

      result = text_to_video.run(**create_params)
      expect(result.status).to eq("completed")
      expect(result.videos.first.url).to eq("https://cdn.runapi.ai/public/samples/source.mp4")
    end
  end
end
