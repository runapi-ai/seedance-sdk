import pytest

from runapi.core import config
from runapi.core.errors import AuthenticationError
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
        )]
    assert isinstance(result, TextToVideoResponse)


def test_get_fetches_by_id():
    fake = FakeHttp({"id": "t1", "status": "processing"})
    client = SeedanceClient(api_key="k", http_client=fake)
    client.text_to_video.get("t1")
    assert fake.calls == [("get", "/api/v1/seedance/text_to_video/t1", None)]


def test_run_narrows_completed_type():
    fake = FakeHttp(
        {"id": "t1", "status": "pending"},
        {"id": "t1", "status": "completed", "usage": {"cost": 0.05}, "videos": [{"url": "https://x/y.mp4"}]},
    )
    client = SeedanceClient(api_key="k", http_client=fake)
    result = client.text_to_video.run(
        model="seedance-2.0", prompt="a cinematic city flyover", duration_seconds=8
    )
    assert isinstance(result, CompletedTextToVideoResponse)
    assert result.videos[0].url == "https://x/y.mp4"


# --- per-model request params ---------------------------------------------


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
                "output_resolution": "4k"},
        )]


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
