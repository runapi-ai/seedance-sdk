package ai.runapi.seedance.types;

import ai.runapi.core.types.RunApiValue;

abstract class SeedanceValue extends RunApiValue {
  SeedanceValue(String value) {
    super(value);
  }
}
