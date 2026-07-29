# Seedance Ruby SDK for RunAPI

The Seedance Ruby SDK is the language-specific package for Seedance on RunAPI. Use this package for video generation, animation, and video editing workflows when your application needs request bodies, task status lookup, and consistent RunAPI errors in Ruby.

This README is the Ruby package guide inside the public `seedance-sdk` repository. For the repository overview, start at `../README.md`; for model details, use https://runapi.ai/models/seedance; for API reference, use https://runapi.ai/docs/api/seedance/text-to-video; for SDK docs, use https://runapi.ai/docs/resources/sdks.

## Install

```bash
gem install runapi-seedance
```

## Quick start

```ruby
require "runapi/seedance"

client = RunApi::Seedance::Client.new
task = client.text_to_video.create(
  # Pass the Seedance JSON request body from https://runapi.ai/docs/api/seedance/text-to-video.
)
status = client.text_to_video.get(task.id)
```

Use `create` when you want to submit a task and return quickly, `get` when you need the latest task state, and `run` when a script should create and poll until completion. In web request handlers, prefer `create` plus webhook or later `get` polling so a worker is not held open.

RunAPI-generated file URLs are temporary. Download and store generated images, videos, audio, or other files in your own durable storage within 7 days; do not treat returned URLs as long-term assets.

## Language notes

Use Ruby keyword arguments and the `RunApi::Seedance` error classes when building video jobs, Rails workers, or scripts. The available resources are `text_to_video`. Keep `RUNAPI_API_KEY` in the environment or your secret manager; never commit API keys or callback secrets.

## Links

- Model page: https://runapi.ai/models/seedance
- SDK docs: https://runapi.ai/docs/resources/sdks
- Product docs: https://runapi.ai/docs/api/seedance/text-to-video
- Pricing and rate limits: https://runapi.ai/models/seedance/v1-lite
- Provider comparison: https://runapi.ai/providers/bytedance
- Full catalog: https://runapi.ai/models
- Repository: https://github.com/runapi-ai/seedance-sdk

## License

Licensed under the Apache License, Version 2.0.
