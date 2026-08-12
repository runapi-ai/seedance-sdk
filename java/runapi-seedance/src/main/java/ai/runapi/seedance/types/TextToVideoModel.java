package ai.runapi.seedance.types;

import com.fasterxml.jackson.annotation.JsonCreator;

/** Model slug for text to video operations. */
public final class TextToVideoModel extends SeedanceValue {
  /** seedance-1.5-pro model slug. */
  public static final TextToVideoModel SEEDANCE_1_5_PRO = new TextToVideoModel("seedance-1.5-pro");
  /** seedance-2.0 model slug. */
  public static final TextToVideoModel SEEDANCE_2_0 = new TextToVideoModel("seedance-2.0");
  /** seedance-2.0-fast model slug. */
  public static final TextToVideoModel SEEDANCE_2_0_FAST = new TextToVideoModel("seedance-2.0-fast");
  /** seedance-2.5 model slug. */
  public static final TextToVideoModel SEEDANCE_2_5 = new TextToVideoModel("seedance-2.5");
  /** seedance-2-mini model slug. */
  public static final TextToVideoModel SEEDANCE_2_MINI = new TextToVideoModel("seedance-2-mini");
  /** seedance-v1-pro model slug. */
  public static final TextToVideoModel SEEDANCE_V1_PRO = new TextToVideoModel("seedance-v1-pro");
  /** seedance-v1-pro-fast model slug. */
  public static final TextToVideoModel SEEDANCE_V1_PRO_FAST = new TextToVideoModel("seedance-v1-pro-fast");

  /** Creates a model value from a literal model slug. */
  @JsonCreator
  public TextToVideoModel(String value) {
    super(value);
  }
}
