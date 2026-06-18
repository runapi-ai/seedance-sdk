# Seedance API Python SDK for RunAPI

The seedance api Python SDK is the language-specific package for Seedance on RunAPI. Use this seedance api package for text-to-video, image-to-video, video editing, and animation flows when your application needs JSON request bodies, task status lookup, and consistent RunAPI errors in Python.

This seedance api README is the Python package guide inside the public `seedance-sdk` repository. For the repository overview, start at `../README.md`; for model details, use https://runapi.ai/models/seedance; for API reference, use https://runapi.ai/docs#seedance; for SDK docs, use https://runapi.ai/docs#sdk-seedance.

## Install

```bash
pip install runapi-seedance
```

## Quick start

```python
from runapi.seedance import SeedanceClient

client = SeedanceClient()  # reads RUNAPI_API_KEY, or pass api_key="sk-..."

task = client.text_to_video.create(
    model="seedance-2.0",
    prompt="A cat walking through a garden",
    duration_seconds=8,
)
status = client.text_to_video.get(task.id)
```

Use `create` to submit a task and return quickly, `get` to fetch the latest task state, and `run` when a script should create and poll until completion:

```python
result = client.text_to_video.run(
    model="seedance-2.0",
    prompt="A cinematic drone shot over snowy mountains",
    duration_seconds=8,
)
print(result.videos[0].url)
```

In web request handlers, prefer `create` plus webhook or later `get` polling so a worker is not held open.

RunAPI-generated file URLs are temporary. Download and store generated images, videos, audio, or other files in your own durable storage within 7 days; do not treat returned URLs as long-term assets.

## Language notes

Pass parameters as keyword arguments and catch the `runapi.seedance` error classes when building video jobs or scripts. The available resource is `text_to_video`. Keep `RUNAPI_API_KEY` in the environment or your secret manager; never commit API keys or callback secrets.

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
