# frozen_string_literal: true

module RunApi
  module Seedance
    CONTRACT = {
      "text-to-video" => {
        "models" => ["seedance-1.5-pro", "seedance-2-mini", "seedance-2.0", "seedance-2.0-fast", "seedance-2.5", "seedance-v1-pro", "seedance-v1-pro-fast"],
        "fields_by_model" => {
          "seedance-1.5-pro" => {
            "aspect_ratio" => {
              "enum" => ["1:1", "4:3", "3:4", "16:9", "9:16", "21:9"]
            },
            "duration_seconds" => {
              "required" => true,
              "min" => 4,
              "max" => 12,
              "type" => "integer"
            },
            "output_resolution" => {
              "enum" => ["480p", "720p", "1080p"]
            },
            "seed" => {
              "min" => -1,
              "max" => 2147483647,
              "type" => "integer"
            },
            "source_image_urls" => {
              "max_items" => 2
            }
          },
          "seedance-2-mini" => {
            "aspect_ratio" => {
              "enum" => ["1:1", "4:3", "3:4", "16:9", "9:16", "21:9", "auto"]
            },
            "duration_seconds" => {
              "min" => 4,
              "max" => 15,
              "type" => "integer"
            },
            "output_resolution" => {
              "enum" => ["480p", "720p"]
            },
            "reference_audio_urls" => {
              "max_items" => 3
            },
            "reference_image_urls" => {
              "max_items" => 9
            },
            "reference_video_urls" => {
              "max_items" => 3
            }
          },
          "seedance-2.0" => {
            "aspect_ratio" => {
              "enum" => ["1:1", "4:3", "3:4", "16:9", "9:16", "21:9", "auto"]
            },
            "duration_seconds" => {
              "min" => 4,
              "max" => 15,
              "type" => "integer"
            },
            "output_resolution" => {
              "enum" => ["480p", "720p", "1080p", "4k"]
            },
            "reference_audio_urls" => {
              "max_items" => 3
            },
            "reference_image_urls" => {
              "max_items" => 9
            },
            "reference_video_urls" => {
              "max_items" => 3
            }
          },
          "seedance-2.0-fast" => {
            "aspect_ratio" => {
              "enum" => ["1:1", "4:3", "3:4", "16:9", "9:16", "21:9", "auto"]
            },
            "duration_seconds" => {
              "min" => 4,
              "max" => 15,
              "type" => "integer"
            },
            "output_resolution" => {
              "enum" => ["480p", "720p"]
            },
            "reference_audio_urls" => {
              "max_items" => 3
            },
            "reference_image_urls" => {
              "max_items" => 9
            },
            "reference_video_urls" => {
              "max_items" => 3
            }
          },
          "seedance-2.5" => {
            "aspect_ratio" => {
              "enum" => ["1:1", "4:3", "3:4", "16:9", "9:16", "21:9", "auto"]
            },
            "duration_seconds" => {
              "enum" => [-1, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30],
              "type" => "integer"
            },
            "model" => {
              "required" => true
            },
            "output_format" => {
              "enum" => ["mp4", "mov"]
            },
            "output_resolution" => {
              "enum" => ["480p", "720p", "1080p"]
            },
            "prompt" => {
              "required" => true,
              "min" => 3,
              "max" => 30000,
              "length" => true
            },
            "reference_audio_urls" => {
              "max_items" => 10
            },
            "reference_image_urls" => {
              "max_items" => 30
            },
            "reference_video_urls" => {
              "max_items" => 10
            }
          },
          "seedance-v1-pro" => {
            "aspect_ratio" => {
              "enum" => ["1:1", "4:3", "3:4", "16:9", "9:16", "21:9"]
            },
            "duration_seconds" => {
              "enum" => [5, 10],
              "required" => true,
              "type" => "integer"
            },
            "output_resolution" => {
              "enum" => ["480p", "720p", "1080p"]
            },
            "seed" => {
              "type" => "integer"
            }
          },
          "seedance-v1-pro-fast" => {
            "duration_seconds" => {
              "enum" => [5, 10],
              "required" => true,
              "type" => "integer"
            },
            "first_frame_image_url" => {
              "required" => true
            },
            "output_resolution" => {
              "enum" => ["720p", "1080p"]
            },
            "seed" => {
              "min" => -1,
              "max" => 2147483647,
              "type" => "integer"
            }
          }
        },
        "rules" => [{
          "when" => {
            "model" => "seedance-2.5",
            "first_frame_image_url" => {
              "present" => true
            }
          },
          "forbidden" => ["reference_image_urls", "reference_video_urls", "reference_audio_urls"]
        }, {
          "when" => {
            "model" => "seedance-2.5",
            "last_frame_image_url" => {
              "present" => true
            }
          },
          "required" => ["first_frame_image_url"],
          "forbidden" => ["reference_image_urls", "reference_video_urls", "reference_audio_urls"]
        }, {
          "when" => {
            "model" => "seedance-1.5-pro"
          },
          "forbidden" => ["first_frame_image_url", "last_frame_image_url", "reference_image_urls", "reference_video_urls", "reference_audio_urls", "web_search", "return_last_frame", "output_format"]
        }, {
          "when" => {
            "model" => "seedance-2-mini"
          },
          "forbidden" => ["source_image_urls", "lock_camera", "seed", "enable_safety_checker", "return_last_frame", "output_format"]
        }, {
          "when" => {
            "model" => "seedance-2.0"
          },
          "forbidden" => ["source_image_urls", "lock_camera", "seed", "return_last_frame", "output_format"]
        }, {
          "when" => {
            "model" => "seedance-2.0-fast"
          },
          "forbidden" => ["source_image_urls", "lock_camera", "seed", "return_last_frame", "output_format"]
        }, {
          "when" => {
            "model" => "seedance-2.5"
          },
          "forbidden" => ["source_image_urls", "lock_camera", "seed"]
        }, {
          "when" => {
            "model" => "seedance-v1-pro"
          },
          "forbidden" => ["source_image_urls", "last_frame_image_url", "reference_image_urls", "reference_video_urls", "reference_audio_urls", "web_search", "generate_audio", "return_last_frame", "output_format"]
        }, {
          "when" => {
            "model" => "seedance-v1-pro-fast"
          },
          "forbidden" => ["aspect_ratio", "source_image_urls", "lock_camera", "last_frame_image_url", "reference_image_urls", "reference_video_urls", "reference_audio_urls", "web_search", "generate_audio", "return_last_frame", "output_format"]
        }]
      }
    }.freeze
  end
end
