# Seedance API Go SDK for RunAPI

The seedance api Go SDK is the language-specific package for Seedance on RunAPI. Use this seedance api package for text-to-video, image-to-video, video-to-video, animation, and edit flows when your application needs JSON request bodies, task status lookup, and consistent RunAPI errors in Go.

This seedance api README is the Go package guide inside the public `seedance-sdk` repository. For the repository overview, start at `../README.md`; for model details, use https://runapi.ai/models/seedance; for API reference, use https://runapi.ai/docs#seedance; for SDK docs, use https://runapi.ai/docs#sdk-seedance.

## Install

```bash
go get github.com/runapi-ai/seedance-sdk/go@latest
```

## Quick start

```go
import (
  "context"

  "github.com/runapi-ai/seedance-sdk/go/seedance"
)

client, err := seedance.NewClient()
task, err := client.Generations.Create(context.Background(), seedance.GenerationParams{
  // Pass the Seedance JSON request body from https://runapi.ai/docs#seedance.
})
status, err := client.Generations.Get(context.Background(), task.ID)
```

Use `create` when you want to submit a task and return quickly, `get` when you need the latest task state, and `run` when a script should create and poll until completion. In web request handlers, prefer `create` plus webhook or later `get` polling so a worker is not held open.

## Language notes

Use the public Go module with `github.com/runapi-ai/core-sdk/go` options when building video services, CLIs, or workers. The available resources include generations. Keep `RUNAPI_API_KEY` in the environment or your secret manager; never commit API keys or callback secrets.

## Links

- Model page: https://runapi.ai/models/seedance
- SDK docs: https://runapi.ai/docs#sdk-seedance
- Product docs: https://runapi.ai/docs#seedance
- Pricing and rate limits: https://runapi.ai/models/seedance/v1-lite
- Provider comparison: https://runapi.ai/providers/bytedance
- Full catalog: https://runapi.ai/models
- Repository: https://github.com/runapi-ai/seedance-sdk

## License

Licensed under the Apache License, Version 2.0.
