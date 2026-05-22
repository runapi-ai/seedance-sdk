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
        duration: 8,
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'A cat walking through a garden',
            model: 'seedance-2.0',
            aspect_ratio: '16:9',
            duration: 8,
          },
        }
      );
      expect(result).toEqual(mockResponse);
    });

    it('should send correct request for seedance-1.5-pro with input_urls', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-456' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      const result = await textToVideo.create({
        prompt: 'The flower blooms',
        model: 'seedance-1.5-pro',
        aspect_ratio: '16:9',
        resolution: '720p',
        duration: 8,
        input_urls: ['https://example.com/flower.jpg'],
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'The flower blooms',
            model: 'seedance-1.5-pro',
            aspect_ratio: '16:9',
            resolution: '720p',
            duration: 8,
            input_urls: ['https://example.com/flower.jpg'],
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
        first_frame_url: 'https://example.com/start.jpg',
        last_frame_url: 'https://example.com/end.jpg',
        duration: 10,
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'A sunrise over the ocean',
            model: 'seedance-2.0',
            first_frame_url: 'https://example.com/start.jpg',
            last_frame_url: 'https://example.com/end.jpg',
            duration: 10,
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
        reference_video_urls: ['https://example.com/dance.mp4'],
        reference_image_urls: ['https://example.com/person.jpg'],
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            prompt: 'A person dancing in the same style',
            model: 'seedance-2.0-fast',
            reference_video_urls: ['https://example.com/dance.mp4'],
            reference_image_urls: ['https://example.com/person.jpg'],
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
        callback_url: 'https://example.com/callback',
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
            callback_url: 'https://example.com/callback',
            generate_audio: true,
            web_search: false,
          },
        }
      );
    });

    it('should send correct request for seedance-v1-lite text-to-video', async () => {
      const mockResponse: TaskCreateResponse = { id: 'task-v1-lite' };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      await textToVideo.create({
        model: 'seedance-v1-lite',
        prompt: 'A boat at dawn',
        aspect_ratio: '16:9',
        resolution: '720p',
        duration: '5',
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
            resolution: '720p',
            duration: '5',
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
        input_urls: ['https://example.com/cup.png'],
        resolution: '1080p',
        duration: '5',
      });

      expect(mockHttp.request).toHaveBeenCalledWith(
        'POST',
        '/api/v1/seedance/text_to_video',
        {
          body: {
            model: 'seedance-v1-pro-fast',
            prompt: 'Espresso pour',
            input_urls: ['https://example.com/cup.png'],
            resolution: '1080p',
            duration: '5',
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
          { url: 'https://example.com/video.mp4' },
        ],
        last_frame_url: 'https://example.com/last-frame.png',
      };
      vi.mocked(mockHttp.request).mockResolvedValueOnce(mockResponse);

      const textToVideo = new TextToVideo(mockHttp);
      const result = await textToVideo.get('task-123');

      expect(result.status).toBe('completed');
      expect(result.videos).toHaveLength(1);
      expect(result.videos?.[0].url).toBe('https://example.com/video.mp4');
      expect(result.last_frame_url).toBe('https://example.com/last-frame.png');
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
          { url: 'https://example.com/video.mp4' },
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
