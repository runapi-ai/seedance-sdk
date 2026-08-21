import pytest

from runapi.core import config
from runapi.core.errors import AuthenticationError, ValidationError
from runapi.seedance import SeedanceClient
from runapi.seedance.resources.text_to_video import TextToVideo
from runapi.seedance.types import CompletedTextToVideoResponse, TextToVideoResponse


class FakeHttp:
    def __init__(self, *responses):
        self._responses = list(responses)
        self.calls = []

    def request(self, method, path, body=None, options=None):
        self.calls.append((method, path, body))
        if self._responses:
            return self._responses.pop(0)
        return {"id": "task_1", "status": "pending"}


@pytest.fixture(autouse=True)
def reset_config(monkeypatch):
    monkeypatch.delenv("RUNAPI_API_KEY", raising=False)
    monkeypatch.setattr(config, "api_key", None)
    yield


# --- auth -----------------------------------------------------------------


def test_accepts_api_key_parameter():
    assert isinstance(SeedanceClient(api_key="k", http_client=FakeHttp()), SeedanceClient)


def test_falls_back_to_global(monkeypatch):
    monkeypatch.setattr(config, "api_key", "global-key")
    assert isinstance(SeedanceClient(http_client=FakeHttp()), SeedanceClient)


def test_falls_back_to_env(monkeypatch):
    monkeypatch.setenv("RUNAPI_API_KEY", "env-key")
    assert isinstance(SeedanceClient(http_client=FakeHttp()), SeedanceClient)


def test_raises_without_api_key():
    with pytest.raises(AuthenticationError, match="API key is required"):
        SeedanceClient()


# --- injection / accessors ------------------------------------------------


def test_uses_injected_http_client():
    fake = FakeHttp()
    client = SeedanceClient(api_key="k", http_client=fake)
    assert client.text_to_video._http is fake


def test_exposes_resource_accessors():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    assert isinstance(client.text_to_video, TextToVideo)


# --- request shapes -------------------------------------------------------


def test_create_posts_compacted_body():
    fake = FakeHttp({"id": "t1", "status": "pending"})
    client = SeedanceClient(api_key="k", http_client=fake)
    result = client.text_to_video.create(
        model="seedance-2.0", prompt="a serene lake at dawn", duration_seconds=8, seed=None
    )
    assert fake.calls == [
        (
            "post",
            "/api/v1/seedance/text_to_video",
            {"model": "seedance-2.0", "prompt": "a serene lake at dawn", "duration_seconds": 8},
        ),
    ]
    assert isinstance(result, TextToVideoResponse)


def test_get_fetches_by_id():
    fake = FakeHttp({"id": "t1", "status": "processing"})
    client = SeedanceClient(api_key="k", http_client=fake)
    client.text_to_video.get("t1")
    assert fake.calls == [("get", "/api/v1/seedance/text_to_video/t1", None)]


def test_run_narrows_completed_type():
    fake = FakeHttp(
        {"id": "t1", "status": "pending"},
        {"id": "t1", "status": "completed", "videos": [{"url": "https://x/y.mp4"}]},
    )
    client = SeedanceClient(api_key="k", http_client=fake)
    result = client.text_to_video.run(
        model="seedance-2.0", prompt="a cinematic city flyover", duration_seconds=8
    )
    assert isinstance(result, CompletedTextToVideoResponse)
    assert result.videos[0].url == "https://x/y.mp4"


# --- validation -----------------------------------------------------------


def test_requires_model():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(ValidationError, match="model must be one of:"):
        client.text_to_video.create(prompt="a serene lake at dawn")


def test_rejects_unknown_model():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(ValidationError, match="model must be one of:"):
        client.text_to_video.create(model="nope", prompt="a serene lake at dawn")


def test_requires_prompt():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(ValidationError, match="prompt is required"):
        client.text_to_video.create(model="seedance-2.0")


def test_prompt_length_bounds():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="prompt length must be between 3 and 20000 characters"
    ):
        client.text_to_video.create(model="seedance-2.0", prompt="hi", duration_seconds=8)


# --- conditional validators per model version -----------------------------


def test_v2_aspect_ratio_enum():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(ValidationError, match="aspect_ratio must be one of:"):
        client.text_to_video.create(
            model="seedance-2.0", prompt="a serene lake at dawn", aspect_ratio="bogus"
        )


def test_v2_fast_resolution_excludes_1080p():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(ValidationError, match="output_resolution must be one of:"):
        client.text_to_video.create(
            model="seedance-2.0-fast", prompt="a serene lake at dawn", output_resolution="1080p"
        )


def test_v2_mini_accepts_reference_mode():
    http = FakeHttp([{"id": "task-mini", "status": "processing"}])
    client = SeedanceClient(api_key="k", http_client=http)

    client.text_to_video.create(
        model="seedance-2-mini",
        prompt="a compact cinematic scene",
        reference_video_urls=["https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"],
        reference_audio_urls=["https://cdn.runapi.ai/public/samples/music.mp3"],
        output_resolution="720p",
        aspect_ratio="auto",
        duration_seconds=8,
        generate_audio=False,
    )

    assert http.calls[0][2]["model"] == "seedance-2-mini"


def test_v2_5_accepts_multimodal_fields():
    http = FakeHttp({"id": "task-25", "status": "processing"})
    client = SeedanceClient(api_key="k", http_client=http)

    client.text_to_video.create(
        model="seedance-2.5",
        prompt="Match the reference media",
        reference_image_urls=["https://cdn.runapi.ai/public/samples/reference.jpg"],
        reference_video_urls=["https://cdn.runapi.ai/public/samples/reference.mp4"],
        output_resolution="1080p",
        duration_seconds=-1,
        return_last_frame=True,
        output_format="mov",
    )

    assert http.calls[0][2]["model"] == "seedance-2.5"
    assert http.calls[0][2]["output_resolution"] == "1080p"
    assert http.calls[0][2]["return_last_frame"] is True
    assert http.calls[0][2]["output_format"] == "mov"


def test_v2_mini_resolution_excludes_1080p():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(ValidationError, match="output_resolution must be one of:"):
        client.text_to_video.create(
            model="seedance-2-mini", prompt="a serene lake at dawn", output_resolution="1080p"
        )


def test_v2_accepts_generated_4k():
    fake = FakeHttp({"id": "t1", "status": "pending"})
    client = SeedanceClient(api_key="k", http_client=fake)

    client.text_to_video.create(
        model="seedance-2.0", prompt="a cinematic city flyover", output_resolution="4k"
    )

    assert fake.calls == [
        (
            "post",
            "/api/v1/seedance/text_to_video",
            {
                "model": "seedance-2.0",
                "prompt": "a cinematic city flyover",
                "output_resolution": "4k",
            },
        ),
    ]


def test_v2_rejects_frame_4k():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError,
        match="first_frame_image_url is not allowed when model is seedance-2.0 and output_resolution is 4k",
    ):
        client.text_to_video.create(
            model="seedance-2.0",
            prompt="a cinematic city flyover",
            output_resolution="4k",
            first_frame_image_url="https://x/a.png",
        )


def test_v2_duration_range():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="duration_seconds must be between 4 and 15"
    ):
        client.text_to_video.create(
            model="seedance-2.0", prompt="a serene lake at dawn", duration_seconds=99
        )


def test_v2_frame_and_reference_conflict():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="Cannot use frame mode and reference mode at the same time"
    ):
        client.text_to_video.create(
            model="seedance-2.0",
            prompt="a serene lake at dawn",
            first_frame_image_url="https://x/a.png",
            reference_image_urls=["https://x/b.png"],
        )


def test_v2_rejects_source_image_urls():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(ValidationError, match="source_image_urls is not allowed when model is seedance-2.0"):
        client.text_to_video.create(
            model="seedance-2.0",
            prompt="a serene lake at dawn",
            source_image_urls=["https://x/a.png"],
        )


def test_1_5_pro_sends_seed():
    fake = FakeHttp({"id": "task_15_seed", "status": "pending"})
    client = SeedanceClient(api_key="k", http_client=fake)
    client.text_to_video.create(
        model="seedance-1.5-pro",
        prompt="a serene lake at dawn",
        aspect_ratio="16:9",
        duration_seconds=4,
        seed=42,
    )

    assert fake.calls[0][2]["seed"] == 42


def test_1_5_pro_requires_duration():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="duration_seconds is required"
    ):
        client.text_to_video.create(model="seedance-1.5-pro", prompt="a serene lake at dawn")


def test_1_5_pro_invalid_duration():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="duration_seconds must be between 4 and 12"
    ):
        client.text_to_video.create(
            model="seedance-1.5-pro", prompt="a serene lake at dawn", duration_seconds=13
        )


def test_1_5_pro_source_image_cap():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="source_image_urls must contain at most 2 items"
    ):
        client.text_to_video.create(
            model="seedance-1.5-pro",
            prompt="a serene lake at dawn",
            duration_seconds=4,
            source_image_urls=["a", "b", "c"],
        )


def test_v1_requires_duration():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="duration_seconds is required"
    ):
        client.text_to_video.create(model="seedance-v1-pro", prompt="a serene lake at dawn")


def test_v1_pro_fast_requires_first_frame():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="first_frame_image_url is required"
    ):
        client.text_to_video.create(
            model="seedance-v1-pro-fast", prompt="a serene lake at dawn", duration_seconds=5
        )


def test_v1_pro_fast_sends_seed():
    fake = FakeHttp({"id": "task_fast_seed", "status": "pending"})
    client = SeedanceClient(api_key="k", http_client=fake)
    client.text_to_video.create(
        model="seedance-v1-pro-fast",
        prompt="animate quickly",
        first_frame_image_url="https://cdn.runapi.ai/public/samples/image.jpg",
        output_resolution="720p",
        duration_seconds=5,
        seed=42,
    )

    assert fake.calls[0][2]["seed"] == 42


def test_v1_image_mode_rejects_aspect_ratio():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="aspect_ratio is not accepted in image-to-video mode"
    ):
        client.text_to_video.create(
            model="seedance-v1-pro",
            prompt="a serene lake at dawn",
            duration_seconds=5,
            first_frame_image_url="https://x/a.png",
            aspect_ratio="1:1",
        )


def test_v1_seed_range():
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="seed must be an integer between -1 and 2147483647"
    ):
        client.text_to_video.create(
            model="seedance-v1-pro",
            prompt="a serene lake at dawn",
            duration_seconds=5,
            seed=-5,
        )


def test_non_numeric_duration_raises_validation_error():
    # Regression: a non-numeric duration must raise the SDK's ValidationError,
    # not a bare ValueError from int(). duration_seconds is type: integer, so the
    # contract validator rejects it as a non-integer (mirroring the gateway)
    # before any int() coercion runs.
    client = SeedanceClient(api_key="k", http_client=FakeHttp())
    with pytest.raises(
        ValidationError, match="duration_seconds must be an integer between 4 and 15"
    ):
        client.text_to_video.create(
            model="seedance-2.0", prompt="a serene lake at dawn", duration_seconds="abc"
        )
