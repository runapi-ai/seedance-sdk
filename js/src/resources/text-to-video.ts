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

export class TextToVideo {
  constructor(private readonly http: HttpClient) {}

  async run(params: TextToVideoParams, options?: RequestOptions & PollingOptions): Promise<CompletedTextToVideoResponse> {
    const { id } = await this.create(params, options);
    const response = await pollUntilComplete<TextToVideoResponse>(() => this.get(id, options), {
      maxWaitMs: options?.maxWaitMs,
      pollIntervalMs: options?.pollIntervalMs,
    });
    return response as CompletedTextToVideoResponse;
  }

  async create(params: TextToVideoParams, options?: RequestOptions): Promise<TaskCreateResponse> {
    return this.http.request<TaskCreateResponse>('POST', ENDPOINT, {
      body: compactParams(params),
      ...options,
    });
  }

  async get(id: string, options?: RequestOptions): Promise<TextToVideoResponse> {
    return this.http.request<TextToVideoResponse>('GET', `${ENDPOINT}/${id}`, {
      ...options,
    });
  }
}
