# frozen_string_literal: true

require "spec_helper"

RSpec.describe RunApi::Seedance::Resources::TextToVideo do
  let(:http) { instance_double(RunApi::Core::HttpClient) }
  let(:text_to_video) { described_class.new(http) }
  let(:endpoint) { "/api/v1/seedance/text_to_video" }

  describe "#create (common validation)" do
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

    it "accepts Seedance 2.5 multimodal fields" do
      params = {
        model: "seedance-2.5",
        prompt: "Match the reference media",
        reference_image_urls: ["https://cdn.runapi.ai/public/samples/reference.jpg"],
        reference_video_urls: ["https://cdn.runapi.ai/public/samples/reference.mp4"],
        output_resolution: "1080p",
        duration_seconds: -1,
        return_last_frame: true,
        output_format: "mov"
      }
      expect(http).to receive(:request).with(:post, endpoint, body: params)
        .and_return("id" => "task-25")

      text_to_video.create(**params)
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
  end

  describe "#create (seedance-v1-*)" do
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
