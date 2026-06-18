import type { HttpClient, RequestOptions, PollingOptions } from '@runapi.ai/core';
import { compactParams } from '@runapi.ai/core';
import { pollUntilComplete } from '@runapi.ai/core/internal';
import type {
  CompletedTextToVideoResponse,
  TextToVideoParams,
  TextToVideoResponse,
  TaskCreateResponse,
} from '../types';

const ENDPOINT = '/api/v1/seedance/text_to_video';

/** Generate video from text prompts, optionally conditioned on reference images, frame images, reference videos, or audio. */
export class TextToVideo {
  constructor(private readonly http: HttpClient) {}

  /**
   * Create a text to video task and wait until complete.
   * @param params Text to video parameters.
   * @param options Per-request and polling overrides.
   * @returns The completed text to video response.
   */
  async run(params: TextToVideoParams, options?: RequestOptions & PollingOptions): Promise<CompletedTextToVideoResponse> {
    const { id } = await this.create(params, options);
    const response = await pollUntilComplete<TextToVideoResponse>(() => this.get(id, options), {
      maxWaitMs: options?.maxWaitMs,
      pollIntervalMs: options?.pollIntervalMs,
    });
    return response as CompletedTextToVideoResponse;
  }

  /**
   * Create a text to video task; returns immediately with a task id.
   * @param params Text to video parameters.
   * @param options Per-request overrides.
   * @returns The task creation result.
   */
  async create(params: TextToVideoParams, options?: RequestOptions): Promise<TaskCreateResponse> {
    return this.http.request<TaskCreateResponse>('POST', ENDPOINT, {
      body: compactParams(params),
      ...options,
    });
  }

  /**
   * Fetch the current status of a text to video task.
   * @param id The task id.
   * @param options Per-request overrides.
   * @returns The current text to video task status.
   */
  async get(id: string, options?: RequestOptions): Promise<TextToVideoResponse> {
    return this.http.request<TextToVideoResponse>('GET', `${ENDPOINT}/${id}`, {
      ...options,
    });
  }
}
