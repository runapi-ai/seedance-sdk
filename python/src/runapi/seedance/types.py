"""Seedance response models."""

from __future__ import annotations

from runapi.core import BaseModel, TaskResponse, optional, required


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
