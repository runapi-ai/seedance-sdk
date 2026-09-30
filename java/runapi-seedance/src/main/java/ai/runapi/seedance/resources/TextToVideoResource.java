package ai.runapi.seedance.resources;

import ai.runapi.core.ClientOptions;
import ai.runapi.core.RequestOptions;
import ai.runapi.core.http.HttpTransport;
import ai.runapi.core.polling.TaskCreateResponse;
import ai.runapi.seedance.types.CompletedTextToVideoResponse;
import ai.runapi.seedance.types.TextToVideoParams;
import ai.runapi.seedance.types.TextToVideoResponse;

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
    return createTask(params.action(), params.toMap(), options);
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
    return runTask(params.action(), params.toMap(), options, TextToVideoResponse.class, CompletedTextToVideoResponse.class);
  }
}
