"""Seedance model lists, enums, and response models."""

from __future__ import annotations

from runapi.core import BaseModel, TaskResponse, optional, required

V1_MODELS = ["seedance-v1-lite", "seedance-v1-pro", "seedance-v1-pro-fast"]

SEED_RANGE = range(-1, 2_147_483_648)

PROMPT_MIN_LENGTH = 3
PROMPT_MAX_LENGTH_1_5 = 2500
PROMPT_MAX_LENGTH_2 = 20000
PROMPT_MAX_LENGTH_V1 = 10000

FRAME_FIELDS = ["first_frame_image_url", "last_frame_image_url"]
REFERENCE_FIELDS = ["reference_image_urls", "reference_video_urls", "reference_audio_urls"]


class Video(BaseModel):
    url = optional(str)


class AsyncTaskResponse(TaskResponse):
    """Seedance async task status response."""

    id = required(str)
    status = optional(str, enum=lambda: TaskResponse.Status.ALL)


class TextToVideoResponse(AsyncTaskResponse):
    """Seedance video generation task status response."""

    videos = optional([lambda: Video])
    last_frame_image_url = optional(str)
    error = optional(str)


class CompletedTextToVideoResponse(TextToVideoResponse):
    """Narrowed response from ``run()`` once polling observes completion."""

    videos = required([lambda: Video])
