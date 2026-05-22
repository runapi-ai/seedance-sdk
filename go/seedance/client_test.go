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
	if _, ok := body["first_frame_url"]; ok {
		t.Fatal("expected empty first_frame_url to be compacted away")
	}
}

func TestTextToVideoCreate15Pro(t *testing.T) {
	stub := &stubHTTPClient{}
	client := NewClientWithHTTP(stub)
	dur := 8
	_, err := client.TextToVideo.Create(context.Background(), TextToVideoParams{
		Prompt:      "a flower blooming",
		Model:       ModelSeedance15Pro,
		AspectRatio: "16:9",
		Duration:    &dur,
		InputURLs:   []string{"https://example.com/flower.jpg"},
	})
	if err != nil {
		t.Fatal(err)
	}
	body := stub.body.(map[string]any)
	if body["model"] != "seedance-1.5-pro" {
		t.Fatalf("unexpected model: %v", body["model"])
	}
	urls, ok := body["input_urls"].([]any)
	if !ok || len(urls) != 1 {
		t.Fatalf("expected input_urls with 1 item, got: %v", body["input_urls"])
	}
}
