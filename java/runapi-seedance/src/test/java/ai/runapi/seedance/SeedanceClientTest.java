package ai.runapi.seedance;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

import ai.runapi.core.RequestOptions;
import ai.runapi.core.errors.ValidationException;
import ai.runapi.core.http.HttpRequest;
import ai.runapi.core.http.HttpResponse;
import ai.runapi.core.http.HttpTransport;
import ai.runapi.core.http.JsonRequestBody;
import ai.runapi.core.json.Json;
import ai.runapi.seedance.types.CompletedTextToVideoResponse;
import ai.runapi.seedance.types.TextToVideoResponse;
import ai.runapi.seedance.types.CompletedTextToVideoResponse;
import ai.runapi.seedance.types.TextToVideoModel;
import ai.runapi.seedance.types.TextToVideoParams;
import ai.runapi.seedance.types.TextToVideoResponse;
import com.fasterxml.jackson.databind.JsonNode;
import java.io.ByteArrayOutputStream;
import java.time.Duration;
import java.util.Collections;
import org.junit.jupiter.api.Test;

class SeedanceClientTest {
  @Test
  void builderCreatesClientAndUniversalResources() {
    SeedanceClient client = SeedanceClient.builder().apiKey("sk-test").build();

    assertNotNull(client.textToVideo());
    assertNotNull(client.files());
    assertNotNull(client.account());
  }

  @Test
  void openValueClassesSerializeAsScalarStrings() throws Exception {
    String json = Json.mapper().writeValueAsString(new TextToVideoModel("seedance-1.5-pro"));

    assertEquals("\"seedance-1.5-pro\"", json);
    assertEquals(new TextToVideoModel("seedance-1.5-pro"), Json.mapper().readValue(json, TextToVideoModel.class));
    assertEquals("seedance-2-mini", TextToVideoModel.SEEDANCE_2_MINI.value());
  }

  @Test
  void createSendsExpectedRequestShape() throws Exception {
    CapturingTransport transport = new CapturingTransport("{\"id\":\"task_123\",\"status\":\"processing\"}");
    SeedanceClient client = SeedanceClient.builder().apiKey("sk-test").transport(transport).build();

    client.textToVideo().create(
        TextToVideoParams.builder()
            .prompt("A small red cube on a plain white table, studio product photo")
            .model(TextToVideoModel.SEEDANCE_1_5_PRO)
            .aspectRatio("1:1")
            .durationSeconds(4)
            .seed(42)
            .build()
    );

    assertEquals("POST", transport.request.getMethod().name());
    assertEquals("/api/v1/seedance/text_to_video", transport.request.getPath());
    JsonNode body = bodyJson(transport.request);
    assertNotNull(body);
    assertEquals(42, body.get("seed").asInt());
  }

  @Test
  void createSendsSeedForV1ProFast() throws Exception {
    CapturingTransport transport = new CapturingTransport("{\"id\":\"task_fast_seed\",\"status\":\"processing\"}");
    SeedanceClient client = SeedanceClient.builder().apiKey("sk-test").transport(transport).build();

    client.textToVideo().create(
        TextToVideoParams.builder()
            .prompt("Animate the frame quickly")
            .model(TextToVideoModel.SEEDANCE_V1_PRO_FAST)
            .firstFrameImageUrl("https://cdn.runapi.ai/public/samples/image.jpg")
            .durationSeconds(5)
            .seed(42)
            .build()
    );

    assertEquals(42, bodyJson(transport.request).get("seed").asInt());
  }

  @Test
  void createSendsSeedance25Fields() throws Exception {
    CapturingTransport transport = new CapturingTransport("{\"id\":\"task_25\",\"status\":\"processing\"}");
    SeedanceClient client = SeedanceClient.builder().apiKey("sk-test").transport(transport).build();

    client.textToVideo().create(
        TextToVideoParams.builder()
            .prompt("Match the reference media")
            .model(TextToVideoModel.SEEDANCE_2_5)
            .referenceImageUrls(java.util.Collections.singletonList("https://cdn.runapi.ai/public/samples/reference.jpg"))
            .referenceVideoUrls(java.util.Collections.singletonList("https://cdn.runapi.ai/public/samples/reference.mp4"))
            .durationSeconds(-1)
            .returnLastFrame(true)
            .outputFormat("mov")
            .build()
    );

    JsonNode body = bodyJson(transport.request);
    assertEquals("seedance-2.5", body.get("model").asText());
    assertEquals(true, body.get("return_last_frame").asBoolean());
    assertEquals("mov", body.get("output_format").asText());
  }

  @Test
  void createAcceptsSeedance2Generated4k() throws Exception {
    CapturingTransport transport = new CapturingTransport("{\"id\":\"task_4k\",\"status\":\"processing\"}");
    SeedanceClient client = SeedanceClient.builder().apiKey("sk-test").transport(transport).build();

    client.textToVideo().create(
        TextToVideoParams.builder()
            .prompt("A cinematic city flyover")
            .model(TextToVideoModel.SEEDANCE_2_0)
            .outputResolution("4k")
            .build()
    );

    JsonNode body = bodyJson(transport.request);
    assertEquals("4k", body.get("output_resolution").asText());
  }

  @Test
  void createRejectsSeedance2Frame4k() {
    CapturingTransport transport = new CapturingTransport("{\"id\":\"unused\",\"status\":\"processing\"}");
    SeedanceClient client = SeedanceClient.builder().apiKey("sk-test").transport(transport).build();

    ValidationException error = assertThrows(
        ValidationException.class,
        () -> client.textToVideo().create(
            TextToVideoParams.builder()
                .prompt("A cinematic city flyover")
                .model(TextToVideoModel.SEEDANCE_2_0)
                .outputResolution("4k")
                .firstFrameImageUrl("https://cdn.runapi.ai/public/samples/first-frame.jpg")
                .build()));
    assertEquals("first_frame_image_url is not allowed when model is seedance-2.0 and output_resolution is 4k", error.getMessage());
  }

  @Test
  void getDecodesTaskResponseAndExtraFields() {
    CapturingTransport transport = new CapturingTransport("{\"id\":\"task_456\",\"status\":\"completed\",\"videos\":[{\"url\":\"https://file.runapi.ai/generated\"}],\"custom\":\"kept\"}");
    SeedanceClient client = SeedanceClient.builder().apiKey("sk-test").transport(transport).build();

    TextToVideoResponse response = client.textToVideo().get("task_456");

    assertEquals("GET", transport.request.getMethod().name());
    assertEquals("/api/v1/seedance/text_to_video/task_456", transport.request.getPath());
    assertEquals("completed", response.getStatus().value());
    assertNotNull(response.getVideos());
    assertEquals("kept", response.extraFields().get("custom").asText());
  }

  @Test
  void runPollsUntilCompletedAndKeepsExtraFields() {
    SequenceTransport transport = new SequenceTransport(
        "{\"id\":\"task_789\",\"status\":\"processing\"}",
        "{\"id\":\"task_789\",\"status\":\"completed\",\"videos\":[{\"url\":\"https://file.runapi.ai/generated\"}],\"custom\":\"kept\"}");
    SeedanceClient client = SeedanceClient.builder().apiKey("sk-test").transport(transport).build();

    CompletedTextToVideoResponse response = client.textToVideo().run(
        TextToVideoParams.builder()
            .prompt("A small red cube on a plain white table, studio product photo")
            .model(TextToVideoModel.SEEDANCE_1_5_PRO)
            .aspectRatio("1:1")
            .durationSeconds(4)
            .build(),
        RequestOptions.builder().pollingInterval(Duration.ofMillis(1)).pollingMaxWait(Duration.ofSeconds(1)).build());

    assertEquals("completed", response.getStatus().value());
    assertNotNull(response.getVideos());
    assertEquals("kept", response.extraFields().get("custom").asText());
    assertEquals(2, transport.calls);
  }

  @Test
  void runRejectsCompletedResponseMissingResultField() {
    SequenceTransport transport = new SequenceTransport(
        "{\"id\":\"task_missing\",\"status\":\"processing\"}",
        "{\"id\":\"task_missing\",\"status\":\"completed\"}");
    SeedanceClient client = SeedanceClient.builder().apiKey("sk-test").transport(transport).build();

    assertThrows(
        ValidationException.class,
        () -> client.textToVideo().run(
                TextToVideoParams.builder()
                    .prompt("A small red cube on a plain white table, studio product photo")
                    .model(TextToVideoModel.SEEDANCE_1_5_PRO)
                    .aspectRatio("1:1")
                    .durationSeconds(4)
                    .build(),
            RequestOptions.builder().pollingInterval(Duration.ofMillis(1)).pollingMaxWait(Duration.ofSeconds(1)).build()));
  }

    @Test
    void coversTexttovideoResourceMethods() {
      CapturingTransport createTransport = new CapturingTransport("{\"id\":\"task_text_to_video\",\"status\":\"processing\"}");
      SeedanceClient createClient = SeedanceClient.builder().apiKey("sk-test").transport(createTransport).build();
      assertNotNull(createClient.textToVideo().create(
              TextToVideoParams.builder()
                  .prompt("A small red cube on a plain white table, studio product photo")
                  .model(TextToVideoModel.SEEDANCE_1_5_PRO)
                  .aspectRatio("1:1")
                  .durationSeconds(4)
                  .build()
      ));

      CapturingTransport createWithOptionsTransport = new CapturingTransport("{\"id\":\"task_text_to_video_options\",\"status\":\"processing\"}");
      SeedanceClient createWithOptionsClient = SeedanceClient.builder().apiKey("sk-test").transport(createWithOptionsTransport).build();
      assertNotNull(createWithOptionsClient.textToVideo().create(
              TextToVideoParams.builder()
                  .prompt("A small red cube on a plain white table, studio product photo")
                  .model(TextToVideoModel.SEEDANCE_1_5_PRO)
                  .aspectRatio("1:1")
                  .durationSeconds(4)
                  .build(),
          RequestOptions.none()));

      CapturingTransport getTransport = new CapturingTransport("{\"id\":\"task_text_to_video\",\"status\":\"completed\",\"videos\":[{\"url\":\"https://file.runapi.ai/generated\"}]}");
      SeedanceClient getClient = SeedanceClient.builder().apiKey("sk-test").transport(getTransport).build();
      assertNotNull(getClient.textToVideo().get("task_text_to_video"));

      CapturingTransport getWithOptionsTransport = new CapturingTransport("{\"id\":\"task_text_to_video_options\",\"status\":\"completed\",\"videos\":[{\"url\":\"https://file.runapi.ai/generated\"}]}");
      SeedanceClient getWithOptionsClient = SeedanceClient.builder().apiKey("sk-test").transport(getWithOptionsTransport).build();
      assertNotNull(getWithOptionsClient.textToVideo().get("task_text_to_video_options", RequestOptions.none()));

      SequenceTransport runTransport = new SequenceTransport(
          "{\"id\":\"task_text_to_video_run\",\"status\":\"processing\"}",
          "{\"id\":\"task_text_to_video_run\",\"status\":\"completed\",\"videos\":[{\"url\":\"https://file.runapi.ai/generated\"}]}");
      SeedanceClient runClient = SeedanceClient.builder().apiKey("sk-test").transport(runTransport).build();
      CompletedTextToVideoResponse runResponse = runClient.textToVideo().run(
              TextToVideoParams.builder()
                  .prompt("A small red cube on a plain white table, studio product photo")
                  .model(TextToVideoModel.SEEDANCE_1_5_PRO)
                  .aspectRatio("1:1")
                  .durationSeconds(4)
                  .build(),
          RequestOptions.builder().pollingInterval(Duration.ofMillis(1)).pollingMaxWait(Duration.ofSeconds(1)).build());
      assertNotNull(runResponse);

      SequenceTransport runWithOptionsTransport = new SequenceTransport(
          "{\"id\":\"task_text_to_video_run_options\",\"status\":\"processing\"}",
          "{\"id\":\"task_text_to_video_run_options\",\"status\":\"completed\",\"videos\":[{\"url\":\"https://file.runapi.ai/generated\"}]}");
      SeedanceClient runWithOptionsClient = SeedanceClient.builder().apiKey("sk-test").transport(runWithOptionsTransport).build();
      assertNotNull(runWithOptionsClient.textToVideo().run(
              TextToVideoParams.builder()
                  .prompt("A small red cube on a plain white table, studio product photo")
                  .model(TextToVideoModel.SEEDANCE_1_5_PRO)
                  .aspectRatio("1:1")
                  .durationSeconds(4)
                  .build(),
          RequestOptions.builder().pollingInterval(Duration.ofMillis(1)).pollingMaxWait(Duration.ofSeconds(1)).build()));
    }

  private static JsonNode bodyJson(HttpRequest request) throws Exception {
    JsonRequestBody body = (JsonRequestBody) request.getBody();
    ByteArrayOutputStream out = new ByteArrayOutputStream();
    body.writeTo(out);
    return Json.mapper().readTree(out.toByteArray());
  }

  private static final class CapturingTransport implements HttpTransport {
    private final String body;
    private HttpRequest request;

    private CapturingTransport(String body) {
      this.body = body;
    }

    public HttpResponse send(HttpRequest request) {
      this.request = request;
      return new HttpResponse(200, body, Collections.<String, java.util.List<String>>emptyMap());
    }

    public void close() {}
  }

  private static final class SequenceTransport implements HttpTransport {
    private final String[] responses;
    private int calls;

    private SequenceTransport(String... responses) {
      this.responses = responses;
    }

    public HttpResponse send(HttpRequest request) {
      String response = responses[Math.min(calls, responses.length - 1)];
      calls++;
      return new HttpResponse(200, response, Collections.<String, java.util.List<String>>emptyMap());
    }

    public void close() {}
  }
}
