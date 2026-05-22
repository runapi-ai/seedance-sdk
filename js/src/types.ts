import type { AsyncTaskStatus } from '@runapi.ai/core';

// Model types
export type SeedanceModel =
  | 'seedance-1.5-pro'
  | 'seedance-2.0'
  | 'seedance-2.0-fast'
  | 'seedance-v1-lite'
  | 'seedance-v1-pro'
  | 'seedance-v1-pro-fast';
export type SeedanceModel2 = 'seedance-2.0' | 'seedance-2.0-fast';
export type SeedanceModelV1 = 'seedance-v1-lite' | 'seedance-v1-pro' | 'seedance-v1-pro-fast';

// Aspect ratios
export type AspectRatio15Pro = '1:1' | '4:3' | '3:4' | '16:9' | '9:16' | '21:9';
export type AspectRatio2 = AspectRatio15Pro | 'auto';
export type AspectRatioV1Lite = '1:1' | '4:3' | '3:4' | '16:9' | '9:16' | '9:21';
export type AspectRatioV1Pro = '1:1' | '4:3' | '3:4' | '16:9' | '9:16' | '21:9';

// Resolutions
export type Resolution15Pro = '480p' | '720p' | '1080p';
export type Resolution2 = '480p' | '720p' | '1080p';
export type ResolutionV1 = '480p' | '720p' | '1080p';
export type ResolutionV1ProFast = '720p' | '1080p';

// V1 duration — only accepts string enums '5' or '10'.
export type DurationV1 = '5' | '10';

// Common fields shared by all generation modes
interface GenerationCommonParams {
  /** Text description of desired video content */
  prompt: string;
  /** URL for completion callback */
  callback_url?: string;
  /** Generate audio track for the video */
  generate_audio?: boolean;
  /** Enable NSFW content check */
  nsfw_checker?: boolean;
}

/**
 * seedance-1.5-pro generation parameters.
 * Supports text-to-video and image-to-video with camera lock.
 */
export interface Generation15ProParams extends GenerationCommonParams {
  model: 'seedance-1.5-pro';
  /** Required for seedance-1.5-pro */
  aspect_ratio: AspectRatio15Pro;
  resolution?: Resolution15Pro;
  /** Fixed values: 4, 8, or 12 seconds */
  duration?: 4 | 8 | 12;
  /** Up to 2 image URLs for image-to-video */
  input_urls?: string[];
  /** Lock camera movement */
  lock_camera?: boolean;
}

// --- seedance-2.0 / seedance-2.0-fast modes (mutually exclusive) ---

/** Common fields for all 2.x modes */
interface Generation2BaseParams extends GenerationCommonParams {
  model: SeedanceModel2;
  aspect_ratio?: AspectRatio2;
  resolution?: Resolution2;
  /** Integer 4-15 */
  duration?: number;
  /** Enable web search for prompt enrichment. */
  web_search?: boolean;
}

/**
 * seedance-2.0/2-fast text-to-video mode.
 * Pure text prompt, no image/reference inputs.
 */
export interface Generation2TextParams extends Generation2BaseParams {}

/**
 * seedance-2.0/2-fast frame mode.
 * Guide generation with first (required) and optional last frame images.
 * Mutually exclusive with reference mode.
 */
export interface Generation2FrameParams extends Generation2BaseParams {
  /** First frame image URL (required for frame mode) */
  first_frame_url: string;
  /** Last frame image URL */
  last_frame_url?: string;
}

/**
 * seedance-2.0/2-fast reference mode.
 * Guide generation with reference images, videos, or audio.
 * Mutually exclusive with frame mode.
 */
export interface Generation2ReferenceParams extends Generation2BaseParams {
  /** Reference image URLs (max 9) */
  reference_image_urls?: string[];
  /** Reference video URLs (max 3, total duration ≤ 15s) */
  reference_video_urls?: string[];
  /** Reference audio URLs (max 3, requires image or video) */
  reference_audio_urls?: string[];
}

// --- seedance-v1-* modes ---

/** Common fields for v1-lite and v1-pro (not v1-pro-fast). */
interface GenerationV1SharedParams extends GenerationCommonParams {
  /** `'5'` or `'10'`. Required. */
  duration: DurationV1;
  resolution?: ResolutionV1;
  /** Lock camera movement */
  lock_camera?: boolean;
  /** Random seed; `-1` for random. Integer in [-1, 2147483647]. */
  seed?: number;
  /** Safety checker toggle */
  enable_safety_checker?: boolean;
}

/**
 * seedance-v1-lite text-to-video or image-to-video. Mode is auto-detected by
 * `input_urls` presence. `last_frame_url` is only valid in image-to-video mode.
 */
export interface GenerationV1LiteParams extends GenerationV1SharedParams {
  model: 'seedance-v1-lite';
  /** Required in text-to-video mode. Omit when `input_urls` is set. */
  aspect_ratio?: AspectRatioV1Lite;
  /** Up to 1 image URL. Triggers image-to-video mode when set. */
  input_urls?: string[];
  /** Ending frame image URL; image-to-video mode only. */
  last_frame_url?: string;
}

/**
 * seedance-v1-pro text-to-video or image-to-video. Mode is auto-detected by
 * `input_urls` presence.
 */
export interface GenerationV1ProParams extends GenerationV1SharedParams {
  model: 'seedance-v1-pro';
  /** Required in text-to-video mode. Omit when `input_urls` is set. */
  aspect_ratio?: AspectRatioV1Pro;
  /** Up to 1 image URL. Triggers image-to-video mode when set. */
  input_urls?: string[];
}

/**
 * seedance-v1-pro-fast image-to-video only. Smaller parameter surface —
 * no `aspect_ratio`, `lock_camera`, `seed`, or `enable_safety_checker`.
 */
export interface GenerationV1ProFastParams extends GenerationCommonParams {
  model: 'seedance-v1-pro-fast';
  /** Required — at least one image URL. */
  input_urls: [string] | [string, ...string[]];
  resolution?: ResolutionV1ProFast;
  duration: DurationV1;
}

/** Discriminated union of all generation parameter variants */
export type TextToVideoParams =
  | Generation15ProParams
  | Generation2TextParams
  | Generation2FrameParams
  | Generation2ReferenceParams
  | GenerationV1LiteParams
  | GenerationV1ProParams
  | GenerationV1ProFastParams;

// Response types

export interface TaskCreateResponse {
  id: string;
}

export interface VideoMetadata {
  url: string;
}

export interface TextToVideoResponse {
  id: string;
  status: AsyncTaskStatus;
  videos?: VideoMetadata[];
  last_frame_url?: string;
  error?: string;
  [key: string]: unknown;
}

/**
 * Resolved response returned by the `run()` method after polling sees
 * `status: 'completed'`. Narrows `videos` to non-optional; `last_frame_url`
 * stays optional because it may be absent.
 */
export type CompletedTextToVideoResponse = TextToVideoResponse & {
  status: 'completed';
  videos: VideoMetadata[];
};
