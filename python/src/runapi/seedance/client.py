"""Seedance client."""

from __future__ import annotations

from typing import Any, Optional

from runapi.core import ProviderClient

from .resources.text_to_video import TextToVideo


class SeedanceClient(ProviderClient):
    """Seedance video generation client.

    Example::

        client = SeedanceClient(api_key="sk-...")
        result = client.text_to_video.run(
            model="seedance-2.0", prompt="A cat walking through a garden"
        )
    """

    def __init__(self, api_key: Optional[str] = None, **options: Any) -> None:
        super().__init__(api_key, **options)
        http = self._http
        self.text_to_video = TextToVideo(http)
