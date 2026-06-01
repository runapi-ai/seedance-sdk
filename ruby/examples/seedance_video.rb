#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "runapi/seedance"

client = RunApi::Seedance::Client.new(
  api_key: ENV.fetch("RUNAPI_API_KEY", "runapi_test_token"),
  base_url: ENV.fetch("RUNAPI_BASE_URL", "http://localhost:3000")
)

# 1. Text-to-video with seedance-2.0
puts "=== Text-to-Video (seedance-2.0) ==="
result = client.text_to_video.run(
  model: "seedance-2.0",
  prompt: "A cat walking gracefully through a sunlit garden",
  aspect_ratio: "16:9",
  duration_seconds: 8
)
puts "Status: #{result["status"]}"
result["videos"]&.each_with_index do |video, i|
  puts "  Video #{i + 1}: #{video["url"]}"
end

# 2. Image-to-video with seedance-1.5-pro
puts "\n=== Image-to-Video (seedance-1.5-pro) ==="
result = client.text_to_video.run(
  model: "seedance-1.5-pro",
  prompt: "The flower blooms and petals scatter in the wind",
  aspect_ratio: "16:9",
  output_resolution: "720p",
  duration_seconds: 8,
  source_image_urls: [ENV.fetch("TEST_IMAGE_URL", "https://cdn.runapi.ai/public/samples/flower.jpg")]
)
puts "Status: #{result["status"]}"
result["videos"]&.each_with_index do |video, i|
  puts "  Video #{i + 1}: #{video["url"]}"
end

# 3. Frame mode with seedance-2.0
puts "\n=== Frame Mode (seedance-2.0) ==="
result = client.text_to_video.run(
  model: "seedance-2.0",
  prompt: "A sunrise over the ocean, camera slowly panning right",
  first_frame_image_url: ENV.fetch("TEST_FIRST_FRAME_URL", "https://cdn.runapi.ai/public/samples/first-frame.jpg"),
  duration_seconds: 10
)
puts "Status: #{result["status"]}"
result["videos"]&.each_with_index do |video, i|
  puts "  Video #{i + 1}: #{video["url"]}"
end
puts "Last frame: #{result["last_frame_image_url"]}" if result["last_frame_image_url"]

# 4. Manual polling (create + get)
puts "\n=== Manual Polling ==="
task = client.text_to_video.create(
  model: "seedance-2.0-fast",
  prompt: "A golden retriever running on a beach"
)
raise "Failed to create task" unless task["id"]
puts "Task ID: #{task["id"]}"

loop do
  status = client.text_to_video.get(task["id"])
  puts "Polling... status=#{status["status"]}"
  break if status["status"] == "completed" || status["status"] == "failed"

  sleep 2
end

# 5. Error handling
puts "\n=== Error Handling ==="
begin
  client.text_to_video.create(model: "invalid-model", prompt: "test")
rescue RunApi::Core::ValidationError => e
  puts "Caught ValidationError: #{e.message}"
end

begin
  client.text_to_video.create(
    model: "seedance-2.0",
    prompt: "test",
    first_frame_image_url: "https://cdn.runapi.ai/public/samples/first-frame.jpg",
    reference_image_urls: ["https://cdn.runapi.ai/public/samples/reference.jpg"]
  )
rescue RunApi::Core::ValidationError => e
  puts "Caught mode conflict: #{e.message}"
end
