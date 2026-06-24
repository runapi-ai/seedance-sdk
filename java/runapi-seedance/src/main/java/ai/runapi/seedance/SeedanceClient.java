package ai.runapi.seedance;

import ai.runapi.core.BaseClient;
import ai.runapi.core.ClientOptions;
import ai.runapi.core.http.HttpTransport;
import java.net.URI;
import ai.runapi.seedance.resources.TextToVideoResource;

/** Seedance model-family Java SDK client. */
public final class SeedanceClient extends BaseClient {
  private final TextToVideoResource textToVideo;

  private SeedanceClient(ClientOptions options) {
    super(options);
    this.textToVideo = new TextToVideoResource(transport(), options());
  }

  /** Creates a new SeedanceClient builder. */
  public static Builder builder() {
    return new Builder();
  }

  /** Text To Video operations. */
  public TextToVideoResource textToVideo() {
    return textToVideo;
  }

  /** Builder for {@link SeedanceClient}. */
  public static final class Builder extends BaseClient.Builder<Builder> {
    private Builder() {}

    /** Sets the API key. If omitted, the SDK reads {@code RUNAPI_API_KEY}. */
    @Override
    public Builder apiKey(String value) {
      return super.apiKey(value);
    }

    /** Sets the RunAPI base URL. If omitted, the SDK reads {@code RUNAPI_BASE_URL}. */
    @Override
    public Builder baseUrl(String value) {
      return super.baseUrl(value);
    }

    /** Sets the RunAPI base URL from a URI. */
    @Override
    public Builder baseUrl(URI value) {
      return super.baseUrl(value);
    }

    /** Sets a custom HTTP transport. User-provided transports are not closed by SDK clients. */
    @Override
    public Builder transport(HttpTransport value) {
      return super.transport(value);
    }

    /** Builds an immutable SeedanceClient. */
    @Override
    public SeedanceClient build() {
      return new SeedanceClient(options.build());
    }
  }
}
