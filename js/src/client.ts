import { BaseClient, type ClientOptions } from '@runapi.ai/core';
import { TextToVideo } from './resources/text-to-video';

/**
 * Seedance video API client.
 *
 * @example
 * ```typescript
 * const client = new SeedanceClient({
 *   apiKey: 'your-api-key',
 *   baseUrl: 'https://runapi.ai',
 * });
 *
 * const result = await client.textToVideo.run({
 *   model: 'seedance-2.0',
 *   prompt: 'A cat walking through a garden',
 * });
 * ```
 */
export class SeedanceClient extends BaseClient {
  /** Video generation operations. */
  public readonly textToVideo: TextToVideo;

  constructor(options: ClientOptions = {}) {
    super(options);
    this.textToVideo = new TextToVideo(this.http);
  }
}
