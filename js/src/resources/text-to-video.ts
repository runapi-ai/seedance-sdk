import type { HttpClient, RequestOptions, PollingOptions, ActionSchema } from '@runapi.ai/core';
import { compactParams, validateParams, ValidationError } from '@runapi.ai/core';
import { pollUntilComplete } from '@runapi.ai/core/internal';
import { contract } from '../contract_gen';
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
    const body = compactParams(params);
    validateParams(contract['text-to-video'] as ActionSchema, body as Record<string, unknown>);
    validateSeedance2FourKMode(body as Record<string, unknown>);
    return this.http.request<TaskCreateResponse>('POST', ENDPOINT, {
      body,
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

const SEEDANCE_2_FOUR_K_UNSUPPORTED_FIELDS = [
  'first_frame_image_url',
  'last_frame_image_url',
  'reference_image_urls',
  'reference_video_urls',
  'reference_audio_urls',
];

function validateSeedance2FourKMode(body: Record<string, unknown>): void {
  if (body.model !== 'seedance-2.0' || body.output_resolution !== '4k') {
    return;
  }

  const field = SEEDANCE_2_FOUR_K_UNSUPPORTED_FIELDS.find((candidate) => isPresent(body[candidate]));
  if (!field) {
    return;
  }

  throw new ValidationError(`${field} is not allowed when model is seedance-2.0 and output_resolution is 4k`);
}

function isPresent(value: unknown): boolean {
  if (value === undefined || value === null) {
    return false;
  }
  if (typeof value === 'string') {
    return value.length > 0;
  }
  if (Array.isArray(value)) {
    return value.length > 0;
  }
  return true;
}
