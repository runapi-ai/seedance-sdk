package ai.runapi.seedance.resources;

import ai.runapi.core.ClientOptions;
import ai.runapi.core.RequestOptions;
import ai.runapi.core.errors.ValidationException;
import ai.runapi.core.http.HttpTransport;
import ai.runapi.core.polling.TaskCreateResponse;
import ai.runapi.seedance.types.CompletedTextToVideoResponse;
import ai.runapi.seedance.types.TextToVideoParams;
import ai.runapi.seedance.types.TextToVideoResponse;
import java.util.Map;

/** Text To Video operations. */
public final class TextToVideoResource extends SeedanceResource {
  /** API endpoint path for text to video operations. */
  public static final String ENDPOINT = "/api/v1/seedance/text_to_video";

  /** Creates a resource bound to the supplied transport and client options. */
  public TextToVideoResource(HttpTransport transport, ClientOptions options) {
    super(transport, options, ENDPOINT);
  }

  /** Creates a text to video task. */
  public TaskCreateResponse create(TextToVideoParams params) {
    return create(params, RequestOptions.none());
  }

  /** Creates a text to video task with per-request options. */
  public TaskCreateResponse create(TextToVideoParams params, RequestOptions options) {
    Map<String, Object> body = params.toMap();
    validateSeedance2FourKMode(body);
    return createTask(params.action(), body, options);
  }

  /** Retrieves a text to video task by ID. */
  public TextToVideoResponse get(String id) {
    return get(id, RequestOptions.none());
  }

  /** Retrieves a text to video task by ID with per-request options. */
  public TextToVideoResponse get(String id, RequestOptions options) {
    return getTask(id, options, TextToVideoResponse.class);
  }

  /** Creates a text to video task and polls until it completes. */
  public CompletedTextToVideoResponse run(TextToVideoParams params) {
    return run(params, RequestOptions.none());
  }

  /** Creates a text to video task with per-request options and polls until it completes. */
  public CompletedTextToVideoResponse run(TextToVideoParams params, RequestOptions options) {
    Map<String, Object> body = params.toMap();
    validateSeedance2FourKMode(body);
    return runTask(params.action(), body, options, TextToVideoResponse.class, CompletedTextToVideoResponse.class);
  }

  private static void validateSeedance2FourKMode(Map<String, Object> body) {
    if (!"seedance-2.0".equals(body.get("model")) || !"4k".equals(body.get("output_resolution"))) {
      return;
    }

    for (String field : new String[] {
      "first_frame_image_url",
      "last_frame_image_url",
      "reference_image_urls",
      "reference_video_urls",
      "reference_audio_urls",
    }) {
      if (isPresent(body.get(field))) {
        throw new ValidationException(field + " is not allowed when model is seedance-2.0 and output_resolution is 4k");
      }
    }
  }

  private static boolean isPresent(Object value) {
    if (value == null) {
      return false;
    }
    if (value instanceof String) {
      return !((String) value).isEmpty();
    }
    if (value instanceof java.util.List<?>) {
      return !((java.util.List<?>) value).isEmpty();
    }
    return true;
  }
}
