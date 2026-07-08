import type { AsyncTaskStatus } from '@runapi.ai/core';

// Model types
export type SeedanceModel =
  | 'seedance-1.5-pro'
  | 'seedance-2.0'
  | 'seedance-2.0-fast'
  | 'seedance-2-mini'
  | 'seedance-v1-lite'
  | 'seedance-v1-pro'
  | 'seedance-v1-pro-fast';
export type SeedanceModel2 = 'seedance-2.0' | 'seedance-2.0-fast' | 'seedance-2-mini';
export type SeedanceModel2WithSafetyChecker = 'seedance-2.0' | 'seedance-2.0-fast';
export type SeedanceModelV1 = 'seedance-v1-lite' | 'seedance-v1-pro' | 'seedance-v1-pro-fast';

// Aspect ratios
export type AspectRatio15Pro = '1:1' | '4:3' | '3:4' | '16:9' | '9:16' | '21:9';
export type AspectRatio2 = AspectRatio15Pro | 'auto';
export type AspectRatioV1Lite = '1:1' | '4:3' | '3:4' | '16:9' | '9:16' | '9:21';
export type AspectRatioV1Pro = '1:1' | '4:3' | '3:4' | '16:9' | '9:16' | '21:9';

// Resolutions
export type Resolution15Pro = '480p' | '720p' | '1080p';
export type Resolution2 = '480p' | '720p' | '1080p' | '4k';
export type ResolutionV1 = '480p' | '720p' | '1080p';
export type ResolutionV1ProFast = '720p' | '1080p';

// V1 duration_seconds accepts 5 or 10 seconds.
export type DurationV1 = 5 | 10;
export type Duration15Pro = number;

// Common fields shared by all generation modes
interface GenerationCommonParams {
  /** Text description of desired video content */
  prompt: string;
  /** URL for completion callback */
  callback_url?: string;
}

interface SafetyCheckerParams {
  /** Content safety check toggle */
  enable_safety_checker?: boolean;
}

interface AudioGenerationParams {
  /** Generate audio track for the video */
  generate_audio?: boolean;
}

/**
 * seedance-1.5-pro generation parameters.
 * Supports text-to-video and image-to-video with camera lock.
 */
export interface Generation15ProParams extends GenerationCommonParams, AudioGenerationParams, SafetyCheckerParams {
  model: 'seedance-1.5-pro';
  /** Required for seedance-1.5-pro */
  aspect_ratio: AspectRatio15Pro;
  output_resolution?: Resolution15Pro;
  /** Integer 4-12 seconds */
  duration_seconds: Duration15Pro;
  /** Up to 2 source image URLs for image-to-video */
  source_image_urls?: string[];
  /** Lock camera movement */
  lock_camera?: boolean;
}

// --- seedance-2.x modes (mutually exclusive) ---

/** Common fields for all 2.x modes */
interface Generation2BaseFields extends GenerationCommonParams, AudioGenerationParams {
  aspect_ratio?: AspectRatio2;
  output_resolution?: Resolution2;
  /** Integer 4-15 */
  duration_seconds?: number;
}

type Generation2ModelFields =
  | ({ model: SeedanceModel2WithSafetyChecker } & SafetyCheckerParams)
  | { model: 'seedance-2-mini' };

interface Generation2TextFields extends Generation2BaseFields {
  /** Enable web search for prompt enrichment in pure text-to-video mode. */
  web_search?: boolean;
  first_frame_image_url?: never;
  last_frame_image_url?: never;
  reference_image_urls?: never;
  reference_video_urls?: never;
  reference_audio_urls?: never;
}

/**
 * seedance-2.x text-to-video mode.
 * Pure text prompt, no image/reference inputs.
 */
export type Generation2TextParams = Generation2TextFields & Generation2ModelFields;

interface Generation2FrameFields extends Generation2BaseFields {
  /** First frame image URL (required for frame mode) */
  first_frame_image_url: string;
  /** Last frame image URL */
  last_frame_image_url?: string;
  web_search?: never;
  reference_image_urls?: never;
  reference_video_urls?: never;
  reference_audio_urls?: never;
}

/**
 * seedance-2.x frame mode.
 * Guide generation with first (required) and optional last frame images.
 * Mutually exclusive with reference mode.
 */
export type Generation2FrameParams = Generation2FrameFields & Generation2ModelFields;

interface Generation2ReferenceFields extends Generation2BaseFields {
  /** Reference image URLs (max 9) */
  reference_image_urls?: string[];
  /** Reference video URLs (max 3, total duration <= 15s) */
  reference_video_urls?: string[];
  /** Reference audio URLs (max 3, requires image or video) */
  reference_audio_urls?: string[];
  first_frame_image_url?: never;
  last_frame_image_url?: never;
  web_search?: never;
}

/**
 * seedance-2.x reference mode.
 * Guide generation with reference images, videos, or audio.
 * Mutually exclusive with frame mode.
 */
export type Generation2ReferenceParams = Generation2ReferenceFields & Generation2ModelFields;

// --- seedance-v1-* modes ---

/** Common fields for v1-lite and v1-pro (not v1-pro-fast). */
interface GenerationV1SharedParams extends GenerationCommonParams, SafetyCheckerParams {
  /** `5` or `10`. Required. */
  duration_seconds: DurationV1;
  output_resolution?: ResolutionV1;
  /** Lock camera movement */
  lock_camera?: boolean;
  /** Random seed; `-1` for random. Integer in [-1, 2147483647]. */
  seed?: number;
}

/**
 * seedance-v1-lite text-to-video or image-to-video. Mode is auto-detected by
 * `first_frame_image_url` presence. `last_frame_image_url` is only valid in image-to-video mode.
 */
export interface GenerationV1LiteParams extends GenerationV1SharedParams {
  model: 'seedance-v1-lite';
  /** Required in text-to-video mode. Omit when `first_frame_image_url` is set. */
  aspect_ratio?: AspectRatioV1Lite;
  /** First frame image URL. Triggers image-to-video mode when set. */
  first_frame_image_url?: string;
  /** Ending frame image URL; image-to-video mode only. */
  last_frame_image_url?: string;
}

/**
 * seedance-v1-pro text-to-video or image-to-video. Mode is auto-detected by
 * `first_frame_image_url` presence.
 */
export interface GenerationV1ProParams extends GenerationV1SharedParams {
  model: 'seedance-v1-pro';
  /** Required in text-to-video mode. Omit when `first_frame_image_url` is set. */
  aspect_ratio?: AspectRatioV1Pro;
  /** First frame image URL. Triggers image-to-video mode when set. */
  first_frame_image_url?: string;
}

/**
 * seedance-v1-pro-fast image-to-video only. Smaller parameter surface —
 * no `aspect_ratio`, `lock_camera`, or `seed`.
 */
export interface GenerationV1ProFastParams extends GenerationCommonParams, SafetyCheckerParams {
  model: 'seedance-v1-pro-fast';
  /** Required first frame image URL. */
  first_frame_image_url: string;
  output_resolution?: ResolutionV1ProFast;
  duration_seconds: DurationV1;
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
  last_frame_image_url?: string;
  error?: string;
  [key: string]: unknown;
}

/**
 * Resolved response returned by the `run()` method after polling sees
 * `status: 'completed'`. Narrows `videos` to non-optional; `last_frame_image_url`
 * stays optional because it may be absent.
 */
export type CompletedTextToVideoResponse = TextToVideoResponse & {
  status: 'completed';
  videos: VideoMetadata[];
};
