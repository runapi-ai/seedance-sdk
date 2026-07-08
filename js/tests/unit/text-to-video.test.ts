import { describe, it, expect, vi, beforeEach } from 'vitest';
import { TextToVideo } from '../../src/resources/text-to-video';
import type { HttpClient } from '@runapi.ai/core';
import type { TextToVideoResponse, TaskCreateResponse } from '../../src/types';

describe('TextToVideo', () => {
  const mockHttp: HttpClient = {
    request: vi.fn(),
  };

  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('create', () => {
    it('should send correct request for text-to-video with seedance-2.0', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-123' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      const result = await textToVideo.create({
        prompt: 'A cat walking through a garden',
        model: 'seedance-2.0',
        aspect_ratio: '16:9',
        duration_seconds: 8,
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'A cat walking through a garden',
            model: 'seedance-2.0',
            aspect_ratio: '16:9',
            duration_seconds: 8,
          },
        }
      );
      expect(result).toEqual(mockResponse);
    });

    it('should send correct request for seedance-1.5-pro with source_image_urls', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-456' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      const result = await textToVideo.create({
        prompt: 'The flower blooms',
        model: 'seedance-1.5-pro',
        aspect_ratio: '16:9',
        output_resolution: '720p',
        duration_seconds: 8,
        source_image_urls: ['https://cdn.runapi.ai/public/samples/flower.jpg'],
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'The flower blooms',
            model: 'seedance-1.5-pro',
            aspect_ratio: '16:9',
            output_resolution: '720p',
            duration_seconds: 8,
            source_image_urls: ['https://cdn.runapi.ai/public/samples/flower.jpg'],
          },
        }
      );
      expect(result).toEqual(mockResponse);
    });

    it('should send correct request for frame mode', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-789' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      await textToVideo.create({
        prompt: 'A sunrise over the ocean',
        model: 'seedance-2.0',
        first_frame_image_url: 'https://cdn.runapi.ai/public/samples/first-frame.jpg',
        last_frame_image_url: 'https://cdn.runapi.ai/public/samples/last-frame.jpg',
        duration_seconds: 10,
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'A sunrise over the ocean',
            model: 'seedance-2.0',
            first_frame_image_url: 'https://cdn.runapi.ai/public/samples/first-frame.jpg',
            last_frame_image_url: 'https://cdn.runapi.ai/public/samples/last-frame.jpg',
            duration_seconds: 10,
          },
        }
      );
    });

    it('should send correct request for reference mode', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-ref' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      await textToVideo.create({
        prompt: 'A person dancing in the same style',
        model: 'seedance-2.0-fast',
        reference_video_urls: ['https://cdn.runapi.ai/public/samples/result.mp4'],
        reference_image_urls: ['https://cdn.runapi.ai/public/samples/person.jpg'],
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'A person dancing in the same style',
            model: 'seedance-2.0-fast',
            reference_video_urls: ['https://cdn.runapi.ai/public/samples/result.mp4'],
            reference_image_urls: ['https://cdn.runapi.ai/public/samples/person.jpg'],
          },
        }
      );
    });

    it('should send correct request for seedance-2-mini reference mode', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-mini' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      await textToVideo.create({
        prompt: 'A compact cinematic scene with matched motion and audio',
        model: 'seedance-2-mini',
        reference_video_urls: ['https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4'],
        reference_audio_urls: ['https://cdn.runapi.ai/public/samples/music.mp3'],
        output_resolution: '720p',
        aspect_ratio: 'auto',
        duration_seconds: 8,
        generate_audio: false,
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'A compact cinematic scene with matched motion and audio',
            model: 'seedance-2-mini',
            reference_video_urls: ['https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4'],
            reference_audio_urls: ['https://cdn.runapi.ai/public/samples/music.mp3'],
            output_resolution: '720p',
            aspect_ratio: 'auto',
            duration_seconds: 8,
            generate_audio: false,
          },
        }
      );
    });

    it('should include optional parameters', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-opt' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      await textToVideo.create({
        prompt: 'Test video',
        model: 'seedance-2.0',
        callback_url: 'https://your-domain.com/api/callback',
        generate_audio: true,
        web_search: false,
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'Test video',
            model: 'seedance-2.0',
            callback_url: 'https://your-domain.com/api/callback',
            generate_audio: true,
            web_search: false,
          },
        }
      );
    });

    it('should accept seedance-2.0 generated 4k requests', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-4k' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      await textToVideo.create({
        prompt: 'A cinematic city flyover',
        model: 'seedance-2.0',
        output_resolution: '4k',
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'A cinematic city flyover',
            model: 'seedance-2.0',
            output_resolution: '4k',
          },
        }
      );
    });

    it('should reject seedance-2.0 4k with frame inputs', async () => {
      const textToVideo = new TextToVideo(mockHttp);

      await expect(textToVideo.create({
        prompt: 'A cinematic city flyover',
        model: 'seedance-2.0',
        output_resolution: '4k',
        first_frame_image_url: 'https://cdn.runapi.ai/public/samples/first-frame.jpg',
      })).rejects.toThrow('first_frame_image_url is not allowed when model is seedance-2.0 and output_resolution is 4k');

      expect(mockHttp.request).not.toHaveBeenCalled();
    });

    it('should send correct request for seedance-v1-lite text-to-video', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-v1-lite' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      await textToVideo.create({
        model: 'seedance-v1-lite',
        prompt: 'A boat at dawn',
        aspect_ratio: '16:9',
        output_resolution: '720p',
        duration_seconds: 5,
        lock_camera: true,
        seed: 42,
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            model: 'seedance-v1-lite',
            prompt: 'A boat at dawn',
            aspect_ratio: '16:9',
            output_resolution: '720p',
            duration_seconds: 5,
            lock_camera: true,
            seed: 42,
          },
        }
      );
    });

    it('should send correct request for seedance-v1-pro-fast image-to-video', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-v1-fast' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      await textToVideo.create({
        model: 'seedance-v1-pro-fast',
        prompt: 'Espresso pour',
        first_frame_image_url: 'https://cdn.runapi.ai/public/samples/cup.png',
        output_resolution: '1080p',
        duration_seconds: 5,
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            model: 'seedance-v1-pro-fast',
            prompt: 'Espresso pour',
            first_frame_image_url: 'https://cdn.runapi.ai/public/samples/cup.png',
            output_resolution: '1080p',
            duration_seconds: 5,
          },
        }
      );
    });
  });

  describe('get', () => {
    it('should fetch task status by ID', async () => {
      const mockResponse: TextToVideoResponse = {
        id: 'task-123',
        status: 'processing',
        model: 'seedance-2.0',
      };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      const result = await textToVideo.get('task-123');

      expect(mockHttp.request).toHaveBeenCalledWith(
        'GET',
        '/api/v1/seedance/text_to_video/task-123',
        {}
      );
      expect(result).toEqual(mockResponse);
    });

    it('should return completed status with videos', async () => {
      const mockResponse: TextToVideoResponse = {
        id: 'task-123',
        status: 'completed',
        model: 'seedance-2.0',
        videos: [
          { url: 'https://cdn.runapi.ai/public/samples/source.mp4' },
        ],
        last_frame_image_url: 'https://cdn.runapi.ai/public/samples/last-frame.png',
      };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      const result = await textToVideo.get('task-123');

      expect(result.status).toBe('completed');
      expect(result.videos).toHaveLength(1);
      expect(result.videos?.[0].url).toBe('https://cdn.runapi.ai/public/samples/source.mp4');
      expect(result.last_frame_image_url).toBe('https://cdn.runapi.ai/public/samples/last-frame.png');
    });

    it('should return failed status with error', async () => {
      const mockResponse: TextToVideoResponse = {
        id: 'task-123',
        status: 'failed',
        model: 'seedance-2.0-fast',
        error: 'Generation failed',
      };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      const result = await textToVideo.get('task-123');

      expect(result.status).toBe('failed');
      expect(result.error).toBe('Generation failed');
    });
  });

  describe('run', () => {
    it('should create and poll until completion', async () => {
      const createResponse: TaskCreateResponse = { id: 'task-123' };
      const processingResponse: TextToVideoResponse = {
        id: 'task-123',
        status: 'processing',
        model: 'seedance-2.0',
      };
      const completedResponse: TextToVideoResponse = {
        id: 'task-123',
        status: 'completed',
        model: 'seedance-2.0',
        videos: [
          { url: 'https://cdn.runapi.ai/public/samples/source.mp4' },
        ],
      };

      vi.mocked(mockHttp.request)
        .mockResolvedValueOnce(createResponse)
        .mockResolvedValueOnce(processingResponse)
        .mockResolvedValueOnce(completedResponse);

      const textToVideo = new TextToVideo(mockHttp);
      const result = await textToVideo.run({
        prompt: 'Test video',
        model: 'seedance-2.0',
      });

      expect(result.status).toBe('completed');
      expect(result.videos).toHaveLength(1);
    });
  });
});
