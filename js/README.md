# Seedance API JavaScript SDK for RunAPI

The seedance api JavaScript SDK is the language-specific package for Seedance on RunAPI. Use this seedance api package for text-to-video, image-to-video, video editing, and animation flows when your application needs JSON request bodies, task status lookup, and consistent RunAPI errors in JavaScript.

This seedance api README is the JavaScript package guide inside the public `seedance-sdk` repository. For the repository overview, start at `../README.md`; for model details, use https://runapi.ai/models/seedance; for API reference, use https://runapi.ai/docs#seedance; for SDK docs, use https://runapi.ai/docs#sdk-seedance.

## Install

```bash
npm install @runapi.ai/seedance
```

## Quick start

```typescript
import { SeedanceClient } from '@runapi.ai/seedance';

const client = new SeedanceClient();
const task = await client.generations.create({
  // Pass the Seedance JSON request body from https://runapi.ai/docs#seedance.
});
const status = await client.generations.get(task.id);
```

Use `create` when you want to submit a task and return quickly, `get` when you need the latest task state, and `run` when a script should create and poll until completion. In web request handlers, prefer `create` plus webhook or later `get` polling so a worker is not held open.

RunAPI-generated file URLs are temporary. Download and store generated images, videos, audio, or other files in your own durable storage within 7 days; do not treat returned URLs as long-term assets.

## Language notes

Use the TypeScript types in `src/types.ts` and the resource classes under `src/resources` when building video applications. The available resources include generations. Keep `RUNAPI_API_KEY` in the environment or your secret manager; never commit API keys or callback secrets.

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
