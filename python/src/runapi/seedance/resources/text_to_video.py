"""Seedance text-to-video resource."""

from __future__ import annotations

from typing import Any, Dict

from runapi.core import Resource, ValidationError

from ..types import (
    ASPECT_RATIOS_1_5,
    ASPECT_RATIOS_2,
    ASPECT_RATIOS_V1_LITE,
    ASPECT_RATIOS_V1_PRO,
    DURATION_2_RANGE,
    DURATIONS_1_5,
    DURATIONS_V1,
    FRAME_FIELDS,
    MODELS,
    PROMPT_MAX_LENGTH_1_5,
    PROMPT_MAX_LENGTH_2,
    PROMPT_MAX_LENGTH_V1,
    PROMPT_MIN_LENGTH,
    REFERENCE_FIELDS,
    RESOLUTIONS_1_5,
    RESOLUTIONS_SEEDANCE_2,
    RESOLUTIONS_SEEDANCE_2_FAST,
    RESOLUTIONS_V1,
    RESOLUTIONS_V1_PRO_FAST,
    SEED_RANGE,
    V1_MODELS,
    CompletedTextToVideoResponse,
    TextToVideoResponse,
)


class TextToVideo(Resource):
    """Generate videos from text prompts, images, or reference media."""

    ENDPOINT = "/api/v1/seedance/text_to_video"

    RESPONSE_CLASS = TextToVideoResponse
    COMPLETED_RESPONSE_CLASS = CompletedTextToVideoResponse

    def run(self, **params: Any) -> Any:
        """Generate a video and poll until it completes.

        Args:
            **params: video generation parameters (model, ...).

        Returns:
            The completed (narrowed) video generation response.
        """
        task = self.create(**params)
        return self._poll_until_complete(lambda: self.get(task.id))

    def create(self, **params: Any) -> Any:
        """Create a video generation task and return immediately with an id.

        Args:
            **params: video generation parameters (model, ...).

        Returns:
            The task creation result with an id.
        """
        compacted = self._compact_params(params)
        self._validate_params(compacted)
        return self._request("post", self.ENDPOINT, body=compacted)

    def get(self, id: str) -> Any:
        """Fetch the current status of a video generation task.

        Args:
            id: The task id returned by ``create``.

        Returns:
            The current task status.
        """
        return self._request("get", f"{self.ENDPOINT}/{id}")

    def _validate_params(self, params: Dict[str, Any]) -> None:
        model = params.get("model")
        if not model:
            raise ValidationError("model is required")
        if model not in MODELS:
            raise ValidationError(f"Invalid model: {model}. Must be one of: {', '.join(MODELS)}")

        prompt = params.get("prompt")
        if not prompt:
            raise ValidationError("prompt is required")

        if model == "seedance-1.5-pro":
            max_prompt = PROMPT_MAX_LENGTH_1_5
        elif model in V1_MODELS:
            max_prompt = PROMPT_MAX_LENGTH_V1
        else:
            max_prompt = PROMPT_MAX_LENGTH_2
        if not (PROMPT_MIN_LENGTH <= len(prompt) <= max_prompt):
            raise ValidationError(
                f"prompt length must be between {PROMPT_MIN_LENGTH} and {max_prompt} characters"
            )

        if model == "seedance-1.5-pro":
            self._validate_1_5_pro(params)
        elif model in V1_MODELS:
            self._validate_v1(params)
        else:
            self._validate_2(params)

    def _validate_v1(self, params: Dict[str, Any]) -> None:
        model = params.get("model")
        has_image = self._field_present(params, "first_frame_image_url")

        if model == "seedance-v1-pro-fast" and not has_image:
            raise ValidationError("seedance-v1-pro-fast requires first_frame_image_url")

        if has_image and self._field_present(params, "aspect_ratio"):
            raise ValidationError(
                "aspect_ratio is not accepted in image-to-video mode; it is derived from the image"
            )

        if self._field_present(params, "last_frame_image_url") and not (
            model == "seedance-v1-lite" and has_image
        ):
            raise ValidationError(
                "last_frame_image_url is only supported by seedance-v1-lite in image-to-video mode"
            )

        unsupported = [
            "source_image_urls",
            "reference_image_urls",
            "reference_video_urls",
            "reference_audio_urls",
            "web_search",
            "generate_audio",
        ]
        self._reject_unsupported(params, unsupported, model)

        if model == "seedance-v1-pro-fast":
            self._reject_unsupported(params, ["lock_camera", "seed"], model)

        duration_seconds = params.get("duration_seconds")
        if not duration_seconds:
            raise ValidationError(
                "duration_seconds is required for Seedance V1; must be one of: "
                f"{', '.join(str(d) for d in DURATIONS_V1)}"
            )
        if duration_seconds not in DURATIONS_V1:
            raise ValidationError(
                f"Invalid duration_seconds for {model}: {duration_seconds}. Must be one of: "
                f"{', '.join(str(d) for d in DURATIONS_V1)}"
            )

        if not has_image:
            aspect_ratios = (
                ASPECT_RATIOS_V1_LITE if model == "seedance-v1-lite" else ASPECT_RATIOS_V1_PRO
            )
            self._validate_optional(params, "aspect_ratio", aspect_ratios)

        resolutions = (
            RESOLUTIONS_V1_PRO_FAST if model == "seedance-v1-pro-fast" else RESOLUTIONS_V1
        )
        self._validate_optional(params, "output_resolution", resolutions)

        seed = params.get("seed")
        if seed is not None:
            if not (isinstance(seed, int) and not isinstance(seed, bool) and seed in SEED_RANGE):
                raise ValidationError(
                    f"seed must be an integer between {SEED_RANGE.start} and {SEED_RANGE.stop - 1}"
                )

    def _validate_1_5_pro(self, params: Dict[str, Any]) -> None:
        self._validate_optional(params, "aspect_ratio", ASPECT_RATIOS_1_5)
        self._validate_optional(params, "output_resolution", RESOLUTIONS_1_5)

        duration_seconds = params.get("duration_seconds")
        if not duration_seconds:
            raise ValidationError(
                "duration_seconds is required for seedance-1.5-pro; must be one of: "
                f"{', '.join(str(d) for d in DURATIONS_1_5)}"
            )

        if duration_seconds not in DURATIONS_1_5:
            raise ValidationError(
                f"Invalid duration_seconds for seedance-1.5-pro: {duration_seconds}. Must be one of: "
                f"{', '.join(str(d) for d in DURATIONS_1_5)}"
            )

        value = params.get("source_image_urls")
        if isinstance(value, list) and len(value) > 2:
            raise ValidationError("source_image_urls accepts at most 2 images for seedance-1.5-pro")

        unsupported = [
            "first_frame_image_url",
            "last_frame_image_url",
            "reference_image_urls",
            "reference_video_urls",
            "reference_audio_urls",
            "web_search",
        ]
        self._reject_unsupported(params, unsupported, "seedance-1.5-pro")

    def _validate_2(self, params: Dict[str, Any]) -> None:
        self._validate_optional(params, "aspect_ratio", ASPECT_RATIOS_2)
        resolutions = (
            RESOLUTIONS_SEEDANCE_2
            if params.get("model") == "seedance-2.0"
            else RESOLUTIONS_SEEDANCE_2_FAST
        )
        self._validate_optional(params, "output_resolution", resolutions)

        duration_seconds = params.get("duration_seconds")
        if duration_seconds is not None:
            try:
                dur_int = int(duration_seconds)
            except (TypeError, ValueError):
                dur_int = None
            if dur_int is None or dur_int not in DURATION_2_RANGE:
                raise ValidationError(
                    f"Invalid duration_seconds for seedance-2.0: {duration_seconds}. "
                    "Must be an integer between 4 and 15"
                )

        unsupported = ["source_image_urls", "lock_camera"]
        self._reject_unsupported(params, unsupported, params.get("model"))

        self._validate_mode_conflicts(params)

    def _validate_mode_conflicts(self, params: Dict[str, Any]) -> None:
        has_frame = any(self._field_present(params, f) for f in FRAME_FIELDS)
        has_reference = any(self._field_present(params, f) for f in REFERENCE_FIELDS)

        if has_frame and has_reference:
            raise ValidationError("Cannot use frame mode and reference mode at the same time")

    def _reject_unsupported(self, params: Dict[str, Any], fields: Any, model: Any) -> None:
        for field in fields:
            if self._field_present(params, field):
                raise ValidationError(f"{field} is not supported for {model}")

    @staticmethod
    def _field_present(params: Dict[str, Any], key: str) -> bool:
        value = params.get(key)
        if value is None:
            return False
        if hasattr(value, "__len__"):
            return len(value) > 0
        return True
