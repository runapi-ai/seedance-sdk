package seedance

// SeedanceModel identifies a Seedance model variant.
type SeedanceModel string

// TaskStatus represents the status of an async generation task.
type TaskStatus string

const (
	ModelSeedance15Pro     SeedanceModel = "seedance-1.5-pro"
	ModelSeedance2         SeedanceModel = "seedance-2"
	ModelSeedance2Fast     SeedanceModel = "seedance-2-fast"
	ModelSeedanceV1Lite    SeedanceModel = "seedance-v1-lite"
	ModelSeedanceV1Pro     SeedanceModel = "seedance-v1-pro"
	ModelSeedanceV1ProFast SeedanceModel = "seedance-v1-pro-fast"
)

// TextToVideoParams contains parameters for creating a video generation task.
type TextToVideoParams struct {
	Prompt      string        `json:"prompt"`
	Model       SeedanceModel `json:"model"`
	CallbackURL string        `json:"callback_url,omitempty"`

	// Common optional fields
	AspectRatio   string `json:"aspect_ratio,omitempty"`
	Resolution    string `json:"resolution,omitempty"`
	Duration      *int   `json:"duration,omitempty"`
	GenerateAudio *bool  `json:"generate_audio,omitempty"`
	NSFWChecker   *bool  `json:"nsfw_checker,omitempty"`

	// seedance-1.5-pro i2v and seedance-v1-* i2v (v1 accepts max 1 URL)
	InputURLs  []string `json:"input_urls,omitempty"`
	LockCamera *bool    `json:"lock_camera,omitempty"`

	// seedance-2/2-fast frame mode; seedance-v1-lite i2v also uses last_frame_url
	FirstFrameURL string `json:"first_frame_url,omitempty"`
	LastFrameURL  string `json:"last_frame_url,omitempty"`

	// seedance-2/2-fast reference mode
	ReferenceImageURLs []string `json:"reference_image_urls,omitempty" help:"optional; max 9 reference images"`
	ReferenceVideoURLs []string `json:"reference_video_urls,omitempty" help:"optional; max 3 videos, total duration ≤ 15s"`
	ReferenceAudioURLs []string `json:"reference_audio_urls,omitempty" help:"optional; max 3 audio files, requires image or video"`

	// seedance-2/2-fast additional options
	WebSearch *bool `json:"web_search,omitempty"`

	// seedance-v1-lite / v1-pro additional options (ignored on other models)
	Seed                *int  `json:"seed,omitempty" help:"optional; random seed in [-1, 2147483647], -1 = random"`
	EnableSafetyChecker *bool `json:"enable_safety_checker,omitempty" help:"optional; content safety check toggle"`
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
	LastFrameURL string          `json:"last_frame_url,omitempty"`
}
