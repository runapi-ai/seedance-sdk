package seedance

import "github.com/runapi-ai/core-sdk/go/core"

// SeedanceModel identifies a Seedance model variant.
type SeedanceModel string

// TaskStatus represents the status of an async generation task.
type TaskStatus string

const (
	// ModelSeedance15Pro is the 1.5-generation pro model. Supports text-to-video
	// and image-to-video (via SourceImageURLs, up to 2 images). Requires
	// AspectRatio and DurationSeconds (4-12). Supports audio generation,
	// camera lock, and seed control.
	ModelSeedance15Pro SeedanceModel = "seedance-1.5-pro"

	// ModelSeedance2 is the latest generation model with the highest quality
	// output. Supports frame mode (first/last frame images), reference mode
	// (up to 9 reference images, 3 videos, 3 audio files), web search, audio
	// generation, and flexible duration (4-15 seconds). Prompts up to 20000
	// characters.
	ModelSeedance2 SeedanceModel = "seedance-2.0"

	// ModelSeedance2Fast trades some quality for faster generation using the
	// same 2.0 feature set as ModelSeedance2.
	ModelSeedance2Fast SeedanceModel = "seedance-2.0-fast"

	// ModelSeedance25 supports text, first/last frame, and multimodal reference
	// generation with automatic or 4-30 second durations.
	ModelSeedance25 SeedanceModel = "seedance-2.5"

	// ModelSeedance2Mini is the compact 2.x model with frame mode, reference
	// mode, audio generation, web search, and 4-15 second duration support.
	ModelSeedance2Mini SeedanceModel = "seedance-2-mini"

	// ModelSeedanceV1Pro is the high-quality V1 model. Supports image-to-video
	// via FirstFrameImageURL, camera lock, and seed control. Prompts up to
	// 10000 characters.
	ModelSeedanceV1Pro SeedanceModel = "seedance-v1-pro"

	// ModelSeedanceV1ProFast is the speed-optimized V1 pro variant. Requires
	// FirstFrameImageURL (image-to-video only). Supports seed control.
	ModelSeedanceV1ProFast SeedanceModel = "seedance-v1-pro-fast"
)

// TextToVideoParams contains parameters for creating a video generation task.
// The same struct serves both text-to-video and image-to-video workflows;
// supplying image fields (SourceImageURLs for 1.5-pro, or FirstFrameImageURL
// for 2.x/v1 models) switches the generation mode.
//
// Key cross-field constraints:
//   - AspectRatio and DurationSeconds are required for seedance-1.5-pro
//   - FirstFrameImageURL is required for seedance-v1-pro-fast (image-to-video only)
//   - ReferenceAudioURLs requires at least one image or video reference
//   - GenerateAudio and WebSearch are only supported on 1.5-pro and 2.x models
//   - Seed is supported on 1.5-pro and v1 models
type TextToVideoParams struct {
	Prompt      string        `json:"prompt" help:"required; text prompt. 1.5-pro: 3-2500 chars; 2.0/2-mini: 3-20000 chars; 2.5: 3-30000 chars; v1: 3-10000 chars"`
	Model       SeedanceModel `json:"model" help:"required; model slug"`
	CallbackURL string        `json:"callback_url,omitempty" help:"optional; HTTPS completion webhook URL"`

	// Common optional fields
	AspectRatio         string `json:"aspect_ratio,omitempty" help:"required for seedance-1.5-pro and v1 text-to-video. 1.5/2.x: 1:1, 4:3, 3:4, 16:9, 9:16, 21:9; output aspect ratio"`
	OutputResolution    string `json:"output_resolution,omitempty" help:"optional; output resolution"`
	DurationSeconds     *int   `json:"duration_seconds,omitempty" help:"required for seedance-1.5-pro: 4-12. Optional for 2.0/2-mini: 4-15; 2.5: -1 for automatic or 4-30. For v1 JSON files, use 5 or 10; duration in seconds"`
	GenerateAudio       *bool  `json:"generate_audio,omitempty" help:"optional; seedance-1.5-pro and 2.x only"`
	EnableSafetyChecker *bool  `json:"enable_safety_checker,omitempty" help:"optional; content safety check toggle"`
	ReturnLastFrame     *bool  `json:"return_last_frame,omitempty" help:"optional for seedance-2.5; return the generated video's last frame"`
	OutputFormat        string `json:"output_format,omitempty" help:"optional for seedance-2.5; output container format"`

	// seedance-1.5-pro image-to-video source images
	SourceImageURLs []string `json:"source_image_urls,omitempty" help:"optional for seedance-1.5-pro image-to-video, max 2 source images"`
	LockCamera      *bool    `json:"lock_camera,omitempty" help:"optional; seedance-1.5-pro and v1-pro only"`

	// seedance-2.x frame mode; seedance-v1-* image-to-video uses first_frame_image_url
	FirstFrameImageURL string `json:"first_frame_image_url,omitempty" help:"required for seedance-v1-pro-fast and optional for v1 image-to-video; seedance-2.x frame mode first frame image URL"`
	LastFrameImageURL  string `json:"last_frame_image_url,omitempty" help:"optional; seedance-2.x frame mode last frame image URL"`

	// seedance-2.x reference mode
	ReferenceImageURLs []string `json:"reference_image_urls,omitempty" help:"optional; max 9 for 2.0/2-mini or 30 for 2.5"`
	ReferenceVideoURLs []string `json:"reference_video_urls,omitempty" help:"optional; max 3 for 2.0/2-mini or 10 for 2.5"`
	ReferenceAudioURLs []string `json:"reference_audio_urls,omitempty" help:"optional; max 3 for 2.0/2-mini or 10 for 2.5"`

	// seedance-2.x additional options
	WebSearch *bool `json:"web_search,omitempty" help:"optional; seedance-2.x only"`

	// seedance-1.5-pro and v1 additional options (ignored on other models)
	Seed *int `json:"seed,omitempty" help:"optional for seedance-1.5-pro and v1 models; random seed in [-1, 2147483647], -1 = random"`
}

// AsyncTaskResponse is the base response for async generation tasks, embedded
// in endpoint-specific response types. It implements the core polling interface.
type AsyncTaskResponse struct {
	core.TaskBillingFacts
	ID     string     `json:"id"`
	Status TaskStatus `json:"status"`
	Error  string     `json:"error,omitempty"`
}

// GetID returns the task identifier used for polling.
func (r AsyncTaskResponse) GetID() string { return r.ID }

// GetStatus returns the current task status as a string.
func (r AsyncTaskResponse) GetStatus() string { return string(r.Status) }

// GetError returns the error message if the task failed, or empty string on success.
func (r AsyncTaskResponse) GetError() string { return r.Error }

// VideoMetadata contains the download URL for a generated video.
type VideoMetadata struct {
	URL string `json:"url"`
}

// TextToVideoResponse is returned when querying a generation task. Videos
// and LastFrameImageURL are populated once the task reaches a completed status.
type TextToVideoResponse struct {
	AsyncTaskResponse
	Videos            []VideoMetadata `json:"videos,omitempty"`
	LastFrameImageURL string          `json:"last_frame_image_url,omitempty"`
}
