<p align="center">
  <a href="https://runapi.ai"><img src="https://runapi.ai/icon.svg" height="56" alt="RunAPI"></a>
</p>

<h3 align="center">
  <a href="https://github.com/runapi-ai/seedance-sdk">Seedance API SDK for RunAPI</a>
</h3>

<p align="center">
  Seedance API SDKs for JavaScript, Ruby, and Go on RunAPI.
</p>

<div align="center">

[![npm](https://img.shields.io/npm/v/@runapi.ai/seedance)](https://www.npmjs.com/package/@runapi.ai/seedance)
[![RubyGems](https://img.shields.io/gem/v/runapi-seedance)](https://rubygems.org/gems/runapi-seedance)
[![Go Reference](https://pkg.go.dev/badge/github.com/runapi-ai/seedance-sdk/go.svg)](https://pkg.go.dev/github.com/runapi-ai/seedance-sdk/go)
[![License](https://img.shields.io/github/license/runapi-ai/seedance-sdk)](https://github.com/runapi-ai/seedance-sdk/blob/main/LICENSE)

</div>
<br/>

The seedance api SDK packages JavaScript, Ruby, and Go clients for Seedance video generation on RunAPI. Use this seedance api SDK for text-to-video, image-to-video, frame-guided, and reference-based video generation workflows.

## Installation

```bash
npm install @runapi.ai/seedance
# or
pnpm add @runapi.ai/seedance
```

## Quick Start

```typescript
import { SeedanceClient } from '@runapi.ai/seedance';

const client = new SeedanceClient({ apiKey: 'your-api-key' });

// Generate a video and wait for completion
const result = await client.textToVideo.run({
  model: 'seedance-2.0',
  prompt: 'A cat walking through a sunlit garden',
  aspect_ratio: '16:9',
  duration: 8,
});

console.log(result.videos?.[0].url);
```

## Models

| Model | Description | Credits |
|-------|-------------|---------|
| `seedance-1.5-pro` | Mature model with image-to-video and camera lock support | 100/call |
| `seedance-2.0` | Newer model with frame guidance and multimodal references | 100/call |
| `seedance-2.0-fast` | Faster, cheaper variant of seedance-2.0 | 50/call |

## Generation Modes

### Text-to-Video (all models)

```typescript
const result = await client.textToVideo.run({
  model: 'seedance-2.0',
  prompt: 'A drone shot over mountains at sunset',
});
```

### Image-to-Video (seedance-1.5-pro only)

```typescript
const result = await client.textToVideo.run({
  model: 'seedance-1.5-pro',
  prompt: 'The flower blooms and petals scatter',
  aspect_ratio: '16:9',
  input_urls: ['https://example.com/flower.jpg'],
});
```

### Frame Mode (seedance-2.0/2-fast only)

Guide generation with first and optional last frame images.

```typescript
const result = await client.textToVideo.run({
  model: 'seedance-2.0',
  prompt: 'A sunrise over the ocean',
  first_frame_url: 'https://example.com/start.jpg',
  last_frame_url: 'https://example.com/end.jpg',
});
```

### Reference Mode (seedance-2.0/2-fast only)

Guide generation with reference images, videos, or audio. **Mutually exclusive with frame mode.**

```typescript
const result = await client.textToVideo.run({
  model: 'seedance-2.0',
  prompt: 'A person dancing in the same style',
  reference_video_urls: ['https://example.com/dance.mp4'],
});
```

## Parameters

### seedance-1.5-pro

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `model` | `'seedance-1.5-pro'` | Yes | Model selection |
| `prompt` | `string` | Yes | Text prompt |
| `aspect_ratio` | `'1:1' \| '4:3' \| '3:4' \| '16:9' \| '9:16' \| '21:9'` | Yes | Video aspect ratio |
| `resolution` | `'480p' \| '720p' \| '1080p'` | No | Output resolution |
| `duration` | `4 \| 8 \| 12` | No | Video duration in seconds |
| `input_urls` | `string[]` | No | Up to 2 image URLs |
| `lock_camera` | `boolean` | No | Lock camera movement |
| `generate_audio` | `boolean` | No | Generate audio track |
| `callback_url` | `string` | No | Completion webhook URL |

### seedance-2.0 / seedance-2.0-fast

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `model` | `'seedance-2.0' \| 'seedance-2.0-fast'` | Yes | Model selection |
| `prompt` | `string` | Yes | Text prompt |
| `aspect_ratio` | `'1:1' \| ... \| 'auto'` | No | Video aspect ratio (`auto` for frame mode only) |
| `resolution` | `'480p' \| '720p' \| '1080p'` | No | Output resolution (`1080p` requires `seedance-2.0`; `seedance-2.0-fast` supports `480p` / `720p`) |
| `duration` | `number` (4-15) | No | Video duration in seconds |
| `first_frame_url` | `string` | No | First frame (frame mode) |
| `last_frame_url` | `string` | No | Last frame (frame mode) |
| `reference_image_urls` | `string[]` | No | Reference images (1-12 total refs) |
| `reference_video_urls` | `string[]` | No | Reference videos (max 3, total duration ≤ 15s) |
| `reference_audio_urls` | `string[]` | No | Reference audio (requires image or video) |
| `web_search` | `boolean` | No | Enable web search |
| `generate_audio` | `boolean` | No | Generate audio track |
| `callback_url` | `string` | No | Completion webhook URL |

## Manual Polling

```typescript
// Create task
const task = await client.textToVideo.create({
  model: 'seedance-2.0-fast',
  prompt: 'A golden retriever running on a beach',
});

// Poll for status
let status = await client.textToVideo.get(task.id);
while (status.status === 'processing') {
  await new Promise(r => setTimeout(r, 2000));
  status = await client.textToVideo.get(task.id);
}
```

For full seedance api documentation including all parameters and response formats, visit https://runapi.ai/docs#seedance.

## Error Handling

```typescript
import { SeedanceClient, ValidationError, InsufficientCreditsError } from '@runapi.ai/seedance';

try {
  await client.textToVideo.run({ model: 'seedance-2.0', prompt: '...' });
} catch (error) {
  if (error instanceof ValidationError) {
    console.error('Invalid parameters:', error.message);
  } else if (error instanceof InsufficientCreditsError) {
    console.error('Not enough credits');
  }
}
```
