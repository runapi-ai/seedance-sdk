package ai.runapi.seedance.types;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Parameters for text to video operations. */
public final class TextToVideoParams {
  private final String prompt;
  private final String model;
  private final String callbackUrl;
  private final String aspectRatio;
  private final String outputResolution;
  private final Integer durationSeconds;
  private final Boolean generateAudio;
  private final Boolean enableSafetyChecker;
  private final List<String> sourceImageUrls;
  private final Boolean lockCamera;
  private final String firstFrameImageUrl;
  private final String lastFrameImageUrl;
  private final List<String> referenceImageUrls;
  private final List<String> referenceVideoUrls;
  private final List<String> referenceAudioUrls;
  private final Boolean webSearch;
  private final Integer seed;

  private TextToVideoParams(Builder builder) {
    this.prompt = builder.prompt;
    this.model = builder.model;
    this.callbackUrl = builder.callbackUrl;
    this.aspectRatio = builder.aspectRatio;
    this.outputResolution = builder.outputResolution;
    this.durationSeconds = builder.durationSeconds;
    this.generateAudio = builder.generateAudio;
    this.enableSafetyChecker = builder.enableSafetyChecker;
    this.sourceImageUrls = SeedanceParamUtils.strings(builder.sourceImageUrls);
    this.lockCamera = builder.lockCamera;
    this.firstFrameImageUrl = builder.firstFrameImageUrl;
    this.lastFrameImageUrl = builder.lastFrameImageUrl;
    this.referenceImageUrls = SeedanceParamUtils.strings(builder.referenceImageUrls);
    this.referenceVideoUrls = SeedanceParamUtils.strings(builder.referenceVideoUrls);
    this.referenceAudioUrls = SeedanceParamUtils.strings(builder.referenceAudioUrls);
    this.webSearch = builder.webSearch;
    this.seed = builder.seed;
  }

  /** Creates a new TextToVideoParams builder. */
  public static Builder builder() {
    return new Builder();
  }

  /** Returns the RunAPI action key for this request. */
  public String action() {
    return "seedance/text-to-video";
  }

  /** Converts these parameters to the JSON request body shape. */
  public Map<String, Object> toMap() {
    Map<String, Object> raw = new LinkedHashMap<String, Object>();
    raw.put("prompt", SeedanceParamUtils.wireValue(prompt));
    raw.put("model", SeedanceParamUtils.wireValue(model));
    raw.put("callback_url", SeedanceParamUtils.wireValue(callbackUrl));
    raw.put("aspect_ratio", SeedanceParamUtils.wireValue(aspectRatio));
    raw.put("output_resolution", SeedanceParamUtils.wireValue(outputResolution));
    raw.put("duration_seconds", SeedanceParamUtils.wireValue(durationSeconds));
    raw.put("generate_audio", SeedanceParamUtils.wireValue(generateAudio));
    raw.put("enable_safety_checker", SeedanceParamUtils.wireValue(enableSafetyChecker));
    raw.put("source_image_urls", SeedanceParamUtils.wireValue(sourceImageUrls));
    raw.put("lock_camera", SeedanceParamUtils.wireValue(lockCamera));
    raw.put("first_frame_image_url", SeedanceParamUtils.wireValue(firstFrameImageUrl));
    raw.put("last_frame_image_url", SeedanceParamUtils.wireValue(lastFrameImageUrl));
    raw.put("reference_image_urls", SeedanceParamUtils.wireValue(referenceImageUrls));
    raw.put("reference_video_urls", SeedanceParamUtils.wireValue(referenceVideoUrls));
    raw.put("reference_audio_urls", SeedanceParamUtils.wireValue(referenceAudioUrls));
    raw.put("web_search", SeedanceParamUtils.wireValue(webSearch));
    raw.put("seed", SeedanceParamUtils.wireValue(seed));
    return SeedanceParamUtils.compact(raw);
  }

  /** Builder for {@link TextToVideoParams}. */
  public static final class Builder {
    private String prompt;
    private String model;
    private String callbackUrl;
    private String aspectRatio;
    private String outputResolution;
    private Integer durationSeconds;
    private Boolean generateAudio;
    private Boolean enableSafetyChecker;
    private List<String> sourceImageUrls;
    private Boolean lockCamera;
    private String firstFrameImageUrl;
    private String lastFrameImageUrl;
    private List<String> referenceImageUrls;
    private List<String> referenceVideoUrls;
    private List<String> referenceAudioUrls;
    private Boolean webSearch;
    private Integer seed;

    private Builder() {}

    /** Sets the text prompt. */
    public Builder prompt(String value) {
      this.prompt = SeedanceParamUtils.requireNonBlank(value, "prompt");
      return this;
    }

    /** Sets the model slug using a typed model value. */
    public Builder model(TextToVideoModel value) {
      this.model = java.util.Objects.requireNonNull(value, "model").value();
      return this;
    }

    /** Sets the model slug using a string value. */
    public Builder model(String value) {
      this.model = SeedanceParamUtils.requireNonBlankTrim(value, "model");
      return this;
    }


    /** Sets the webhook URL for task completion notifications. */
    public Builder callbackUrl(String value) {
      this.callbackUrl = SeedanceParamUtils.requireNonBlank(value, "callbackUrl");
      return this;
    }

    /** Sets the output aspect ratio. */
    public Builder aspectRatio(String value) {
      this.aspectRatio = SeedanceParamUtils.requireNonBlank(value, "aspectRatio");
      return this;
    }

    /** Sets the output resolution. */
    public Builder outputResolution(String value) {
      this.outputResolution = SeedanceParamUtils.requireNonBlank(value, "outputResolution");
      return this;
    }

    /** Sets the duration in seconds. */
    public Builder durationSeconds(int value) {
      this.durationSeconds = value;
      return this;
    }

    /** Sets the generate audio. */
    public Builder generateAudio(boolean value) {
      this.generateAudio = value;
      return this;
    }

    /** Sets the content safety checker toggle. */
    public Builder enableSafetyChecker(boolean value) {
      this.enableSafetyChecker = value;
      return this;
    }

    /** Sets the source image URLs. */
    public Builder sourceImageUrls(List<String> value) {
      this.sourceImageUrls = value;
      return this;
    }

    /** Sets the lock camera. */
    public Builder lockCamera(boolean value) {
      this.lockCamera = value;
      return this;
    }

    /** Sets the first frame image URL. */
    public Builder firstFrameImageUrl(String value) {
      this.firstFrameImageUrl = SeedanceParamUtils.requireNonBlank(value, "firstFrameImageUrl");
      return this;
    }

    /** Sets the last frame image URL. */
    public Builder lastFrameImageUrl(String value) {
      this.lastFrameImageUrl = SeedanceParamUtils.requireNonBlank(value, "lastFrameImageUrl");
      return this;
    }

    /** Sets the reference image URLs. */
    public Builder referenceImageUrls(List<String> value) {
      this.referenceImageUrls = value;
      return this;
    }

    /** Sets the reference video URLs. */
    public Builder referenceVideoUrls(List<String> value) {
      this.referenceVideoUrls = value;
      return this;
    }

    /** Sets the reference audio URLs. */
    public Builder referenceAudioUrls(List<String> value) {
      this.referenceAudioUrls = value;
      return this;
    }

    /** Sets the web search. */
    public Builder webSearch(boolean value) {
      this.webSearch = value;
      return this;
    }

    /** Sets the random seed for seedance-1.5-pro and V1 models; accepted range is -1 through 2147483647. */
    public Builder seed(int value) {
      this.seed = value;
      return this;
    }

    /** Builds immutable text to video parameters. */
    public TextToVideoParams build() {
      return new TextToVideoParams(this);
    }
  }
}
