package seedance

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/runapi-ai/core-sdk/go/core"
)

type stubHTTPClient struct {
	method string
	path   string
	body   any
}

func (s *stubHTTPClient) Request(_ context.Context, method, path string, opts *core.HTTPRequestOptions) (json.RawMessage, error) {
	s.method = method
	s.path = path
	if opts != nil {
		s.body = opts.Body
	}
	return json.RawMessage(`{"id":"task_123","status":"processing"}`), nil
}

func TestTextToVideoCreate(t *testing.T) {
	stub := &stubHTTPClient{}
	client := NewClientWithHTTP(stub)
	_, err := client.TextToVideo.Create(context.Background(), TextToVideoParams{
		Prompt: "a sunset over the ocean",
		Model:  ModelSeedance2,
	})
	if err != nil {
		t.Fatal(err)
	}
	if stub.method != "POST" || stub.path != "/api/v1/seedance/text_to_video" {
		t.Fatalf("unexpected request: %s %s", stub.method, stub.path)
	}
	body := stub.body.(map[string]any)
	if body["prompt"] != "a sunset over the ocean" {
		t.Fatalf("unexpected prompt: %v", body["prompt"])
	}
	if body["model"] != "seedance-2.0" {
		t.Fatalf("unexpected model: %v", body["model"])
	}
}

func TestTextToVideoCreateSeedance2Generated4K(t *testing.T) {
	stub := &stubHTTPClient{}
	client := NewClientWithHTTP(stub)
	_, err := client.TextToVideo.Create(context.Background(), TextToVideoParams{
		Prompt:           "a cinematic city flyover",
		Model:            ModelSeedance2,
		OutputResolution: "4k",
	})
	if err != nil {
		t.Fatal(err)
	}
	body := stub.body.(map[string]any)
	if body["output_resolution"] != "4k" {
		t.Fatalf("unexpected output_resolution: %v", body["output_resolution"])
	}
}

func TestTextToVideoCreateRejectsSeedance2Frame4K(t *testing.T) {
	stub := &stubHTTPClient{}
	client := NewClientWithHTTP(stub)
	_, err := client.TextToVideo.Create(context.Background(), TextToVideoParams{
		Prompt:             "a cinematic city flyover",
		Model:              ModelSeedance2,
		OutputResolution:   "4k",
		FirstFrameImageURL: "https://cdn.runapi.ai/public/samples/first-frame.jpg",
	})
	if err == nil {
		t.Fatal("expected validation error")
	}
	if got := err.Error(); got != "first_frame_image_url is not allowed when model is seedance-2.0 and output_resolution is 4k" {
		t.Fatalf("unexpected error: %s", got)
	}
	if stub.method != "" {
		t.Fatalf("expected no HTTP request, got %s %s", stub.method, stub.path)
	}
}

func TestTextToVideoGet(t *testing.T) {
	stub := &stubHTTPClient{}
	client := NewClientWithHTTP(stub)
	_, err := client.TextToVideo.Get(context.Background(), "task_abc")
	if err != nil {
		t.Fatal(err)
	}
	if stub.method != "GET" || stub.path != "/api/v1/seedance/text_to_video/task_abc" {
		t.Fatalf("unexpected request: %s %s", stub.method, stub.path)
	}
}

func TestTextToVideoCreateCompactsParams(t *testing.T) {
	stub := &stubHTTPClient{}
	client := NewClientWithHTTP(stub)
	_, err := client.TextToVideo.Create(context.Background(), TextToVideoParams{
		Prompt: "a sunset",
		Model:  ModelSeedance2Fast,
	})
	if err != nil {
		t.Fatal(err)
	}
	body := stub.body.(map[string]any)
	if _, ok := body["callback_url"]; ok {
		t.Fatal("expected empty callback_url to be compacted away")
	}
	if _, ok := body["first_frame_image_url"]; ok {
		t.Fatal("expected empty first_frame_image_url to be compacted away")
	}
}

func TestTextToVideoCreateMini(t *testing.T) {
	stub := &stubHTTPClient{}
	client := NewClientWithHTTP(stub)
	dur := 8
	audio := false
	_, err := client.TextToVideo.Create(context.Background(), TextToVideoParams{
		Prompt:             "a compact cinematic scene",
		Model:              ModelSeedance2Mini,
		OutputResolution:   "720p",
		AspectRatio:        "auto",
		DurationSeconds:    &dur,
		GenerateAudio:      &audio,
		ReferenceVideoURLs: []string{"https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"},
		ReferenceAudioURLs: []string{"https://cdn.runapi.ai/public/samples/music.mp3"},
	})
	if err != nil {
		t.Fatal(err)
	}
	body := stub.body.(map[string]any)
	if body["model"] != "seedance-2-mini" {
		t.Fatalf("unexpected model: %v", body["model"])
	}
	if body["output_resolution"] != "720p" {
		t.Fatalf("unexpected output_resolution: %v", body["output_resolution"])
	}
}

func TestTextToVideoCreate15Pro(t *testing.T) {
	stub := &stubHTTPClient{}
	client := NewClientWithHTTP(stub)
	dur := 8
	seed := 42
	_, err := client.TextToVideo.Create(context.Background(), TextToVideoParams{
		Prompt:          "a flower blooming",
		Model:           ModelSeedance15Pro,
		AspectRatio:     "16:9",
		DurationSeconds: &dur,
		SourceImageURLs: []string{"https://cdn.runapi.ai/public/samples/flower.jpg"},
		Seed:            &seed,
	})
	if err != nil {
		t.Fatal(err)
	}
	body := stub.body.(map[string]any)
	if body["model"] != "seedance-1.5-pro" {
		t.Fatalf("unexpected model: %v", body["model"])
	}
	if body["duration_seconds"] != float64(8) {
		t.Fatalf("unexpected duration_seconds: %v", body["duration_seconds"])
	}
	if body["seed"] != float64(42) {
		t.Fatalf("unexpected seed: %v", body["seed"])
	}
	urls, ok := body["source_image_urls"].([]any)
	if !ok || len(urls) != 1 {
		t.Fatalf("expected source_image_urls with 1 item, got: %v", body["source_image_urls"])
	}
}

func TestTextToVideoCreateV1ProFastWithSeed(t *testing.T) {
	stub := &stubHTTPClient{}
	client := NewClientWithHTTP(stub)
	dur := 5
	seed := 42
	_, err := client.TextToVideo.Create(context.Background(), TextToVideoParams{
		Prompt:             "animate the frame quickly",
		Model:              ModelSeedanceV1ProFast,
		FirstFrameImageURL: "https://cdn.runapi.ai/public/samples/image.jpg",
		DurationSeconds:    &dur,
		Seed:               &seed,
	})
	if err != nil {
		t.Fatal(err)
	}
	body := stub.body.(map[string]any)
	if body["seed"] != float64(42) {
		t.Fatalf("unexpected seed: %v", body["seed"])
	}
}
