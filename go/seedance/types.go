package seedance

// SeedanceModel identifies a Seedance model variant.
type SeedanceModel string

// TaskStatus represents the status of an async generation task.
type TaskStatus string

const (
	ModelSeedance15Pro     SeedanceModel = "seedance-1.5-pro"
	ModelSeedance2         SeedanceModel = "seedance-2.0"
	ModelSeedance2Fast     SeedanceModel = "seedance-2.0-fast"
	ModelSeedanceV1Lite    SeedanceModel = "seedance-v1-lite"
	ModelSeedanceV1Pro     SeedanceModel = "seedance-v1-pro"
	ModelSeedanceV1ProFast SeedanceModel = "seedance-v1-pro-fast"
)

// TextToVideoParams contains parameters for creating a video generation task.
type TextToVideoParams struct {
	Prompt      string        `json:"prompt" help:"required; text prompt. 1.5-pro: 3-2500 chars; 2.x: 3-20000 chars; v1: 3-10000 chars"`
	Model       SeedanceModel `json:"model" help:"required; model slug"`
	CallbackURL string        `json:"callback_url,omitempty" help:"optional; HTTPS completion webhook URL"`

	// Common optional fields
	AspectRatio         string `json:"aspect_ratio,omitempty" help:"required for seedance-1.5-pro and v1 text-to-video. 1.5/2.x: 1:1, 4:3, 3:4, 16:9, 9:16, 21:9; output aspect ratio"`
	OutputResolution    string `json:"output_resolution,omitempty" help:"optional; output resolution"`
	DurationSeconds     *int   `json:"duration_seconds,omitempty" help:"required for seedance-1.5-pro: 4, 8, or 12. Optional for 2.x: 4-15. For v1 JSON files, use 5 or 10; duration in seconds"`
	GenerateAudio       *bool  `json:"generate_audio,omitempty" help:"optional; seedance-1.5-pro and 2.x only"`
	EnableSafetyChecker *bool  `json:"enable_safety_checker,omitempty" help:"optional; content safety check toggle"`

	// seedance-1.5-pro image-to-video source images
	SourceImageURLs []string `json:"source_image_urls,omitempty" help:"optional for seedance-1.5-pro image-to-video, max 2 source images"`
	LockCamera      *bool    `json:"lock_camera,omitempty" help:"optional; seedance-1.5-pro, v1-lite, and v1-pro only"`

	// seedance-2.0/2-fast frame mode; seedance-v1-* image-to-video uses first_frame_image_url
	FirstFrameImageURL string `json:"first_frame_image_url,omitempty" help:"required for seedance-v1-pro-fast and optional for v1 image-to-video; seedance-2.x frame mode first frame image URL"`
	LastFrameImageURL  string `json:"last_frame_image_url,omitempty" help:"optional; seedance-2.x frame mode last frame image URL, or v1-lite image-to-video end frame image URL"`

	// seedance-2.0/2-fast reference mode
	ReferenceImageURLs []string `json:"reference_image_urls,omitempty" help:"optional; max 9 reference images"`
	ReferenceVideoURLs []string `json:"reference_video_urls,omitempty" help:"optional; max 3 videos, total duration ≤ 15s"`
	ReferenceAudioURLs []string `json:"reference_audio_urls,omitempty" help:"optional; max 3 audio files, requires image or video"`

	// seedance-2.0/2-fast additional options
	WebSearch *bool `json:"web_search,omitempty" help:"optional; seedance-2.x only"`

	// seedance-v1-lite / v1-pro additional options (ignored on other models)
	Seed *int `json:"seed,omitempty" help:"optional; random seed in [-1, 2147483647], -1 = random"`
}

// AsyncTaskResponse is the base response for async tasks.
type AsyncTaskResponse struct {
	ID     string     `json:"id"`
	Status TaskStatus `json:"status"`
	Error  string     `json:"error,omitempty"`
}

func (r AsyncTaskResponse) GetID() string     { return r.ID }
func (r AsyncTaskResponse) GetStatus() string { return string(r.Status) }
func (r AsyncTaskResponse) GetError() string  { return r.Error }

// VideoMetadata contains metadata about a generated video.
type VideoMetadata struct {
	URL string `json:"url"`
}

// TextToVideoResponse is returned when polling a generation task.
type TextToVideoResponse struct {
	AsyncTaskResponse
	Videos       []VideoMetadata `json:"videos,omitempty"`
	LastFrameImageURL string          `json:"last_frame_image_url,omitempty"`
}
