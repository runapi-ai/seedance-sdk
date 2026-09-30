"""Seedance text-to-video resource."""

from __future__ import annotations

from typing import Any, Optional

from runapi.core import Resource, RequestOptions

from ..types import (
    CompletedTextToVideoResponse,
    TextToVideoResponse,
)


class TextToVideo(Resource):
    """Generate videos from text prompts, images, or reference media."""

    ENDPOINT = "/api/v1/seedance/text_to_video"

    RESPONSE_CLASS = TextToVideoResponse
    COMPLETED_RESPONSE_CLASS = CompletedTextToVideoResponse

    def run(self, options: Optional[RequestOptions] = None, **params: Any) -> Any:
        """Generate a video and poll until it completes.

        Args:
            **params: video generation parameters (model, ...).

        Returns:
            The completed (narrowed) video generation response.
        """
        task = self.create(options=options, **params)
        return self._poll_until_complete(lambda: self.get(task.id, options=options))

    def create(self, options: Optional[RequestOptions] = None, **params: Any) -> Any:
        """Create a video generation task and return immediately with an id.

        Args:
            **params: video generation parameters (model, ...).

        Returns:
            The task creation result with an id.
        """
        compacted = self._compact_params(params)
        return self._request("post", self.ENDPOINT, body=compacted, options=options)

    def get(self, id: str, options: Optional[RequestOptions] = None) -> Any:
        """Fetch the current status of a video generation task.

        Args:
            id: The task id returned by ``create``.

        Returns:
            The current task status.
        """
        return self._request("get", f"{self.ENDPOINT}/{id}", options=options)
