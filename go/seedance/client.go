// Package seedance provides the Seedance video generation API client.
//
//	client, err := seedance.NewClient(option.WithAPIKey("sk-your-api-key"))
//	result, err := client.TextToVideo.Run(ctx, seedance.TextToVideoParams{
//	    Model: seedance.ModelSeedance2, Prompt: "A cat walking through a garden",
//	})
package seedance

import (
	"context"

	"github.com/runapi-ai/core-sdk/go/base"
	"github.com/runapi-ai/core-sdk/go/core"
	"github.com/runapi-ai/core-sdk/go/option"
)

const (
	textToVideoPath = "/api/v1/seedance/text_to_video"
)

// Client is the Seedance video generation API client.
type Client struct {
	base.Base
	// TextToVideo provides video generation operations.
	TextToVideo *TextToVideo
}

// NewClient creates a Seedance client with the given options.
func NewClient(opts ...option.ClientOption) (*Client, error) {
	resolved, err := option.ResolveClientOptions(opts...)
	if err != nil {
		return nil, err
	}
	httpClient, err := core.NewHTTPClient(resolved)
	if err != nil {
		return nil, err
	}
	return NewClientWithHTTP(httpClient), nil
}

// NewClientWithHTTP creates a Seedance client with a pre-configured HTTP transport.
func NewClientWithHTTP(httpClient core.HTTPClient) *Client {
	return &Client{
		Base:        base.New(httpClient),
		TextToVideo: &TextToVideo{http: httpClient},
	}
}

// TextToVideo generates videos from text prompts, optionally conditioned on
// reference images, frame images, reference videos, or audio. The same
// endpoint handles pure text-to-video and image-to-video depending on which
// image/video fields are populated in the params.
type TextToVideo struct{ http core.HTTPClient }

// Create submits an asynchronous video generation task and returns immediately
// with a task ID. Poll with Get or use Run for automatic polling.
func (r *TextToVideo) Create(ctx context.Context, params TextToVideoParams, opts ...option.RequestOption) (*core.TaskCreateResponse, error) {
	requestOptions, _ := option.ResolveRequestOptions(opts...)
	body := core.CompactParams(params)
	if err := core.ValidateParams(contractSchema["text-to-video"], body); err != nil {
		return nil, err
	}
	return core.PostJSON[core.TaskCreateResponse](ctx, r.http, textToVideoPath, body, requestOptions)
}

// Get retrieves the current status and results of a video generation task by ID.
func (r *TextToVideo) Get(ctx context.Context, id string, opts ...option.RequestOption) (*TextToVideoResponse, error) {
	requestOptions, _ := option.ResolveRequestOptions(opts...)
	return core.GetJSON[TextToVideoResponse](ctx, r.http, core.ResourcePath(textToVideoPath, id), requestOptions)
}

// Run submits a video generation task and polls until completion, returning the
// finished result. This is a convenience wrapper around Create + Get polling.
func (r *TextToVideo) Run(ctx context.Context, params TextToVideoParams, opts ...option.RequestOption) (*TextToVideoResponse, error) {
	_, pollingOptions := option.ResolveRequestOptions(opts...)
	return core.RunAsync(ctx, func(ctx context.Context) (*core.TaskCreateResponse, error) { return r.Create(ctx, params, opts...) }, func(ctx context.Context, id string) (*TextToVideoResponse, error) { return r.Get(ctx, id, opts...) }, pollingOptions)
}
