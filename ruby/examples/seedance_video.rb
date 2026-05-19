#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "runapi/seedance"

client = RunApi::Seedance::Client.new(
  api_key: ENV.fetch("RUNAPI_API_KEY", "runapi_test_token"),
  base_url: ENV.fetch("RUNAPI_BASE_URL", "http://localhost:3000")
)

# 1. Text-to-video with seedance-2
puts "=== Text-to-Video (seedance-2) ==="
result = client.text_to_video.run(
  model: "seedance-2",
  prompt: "A cat walking gracefully through a sunlit garden",
  aspect_ratio: "16:9",
  duration: 8
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
  resolution: "720p",
  duration: 8,
  input_urls: [ ENV.fetch("TEST_IMAGE_URL", "https://example.com/flower.jpg") ]
)
puts "Status: #{result["status"]}"
result["videos"]&.each_with_index do |video, i|
  puts "  Video #{i + 1}: #{video["url"]}"
end

# 3. Frame mode with seedance-2
puts "\n=== Frame Mode (seedance-2) ==="
result = client.text_to_video.run(
  model: "seedance-2",
  prompt: "A sunrise over the ocean, camera slowly panning right",
  first_frame_url: ENV.fetch("TEST_FIRST_FRAME_URL", "https://example.com/sunrise-start.jpg"),
  duration: 10
)
puts "Status: #{result["status"]}"
result["videos"]&.each_with_index do |video, i|
  puts "  Video #{i + 1}: #{video["url"]}"
end
puts "Last frame: #{result["last_frame_url"]}" if result["last_frame_url"]

# 4. Manual polling (create + get)
puts "\n=== Manual Polling ==="
task = client.text_to_video.create(
  model: "seedance-2-fast",
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
    model: "seedance-2",
    prompt: "test",
    first_frame_url: "https://example.com/frame.jpg",
    reference_image_urls: [ "https://example.com/ref.jpg" ]
  )
rescue RunApi::Core::ValidationError => e
  puts "Caught mode conflict: #{e.message}"
end
