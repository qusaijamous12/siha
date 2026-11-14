enum TrackedCondition { diabetes, hypertension }

enum MealTiming { beforeMeal, twoHoursAfterMeal }

enum ReadingStatus {
  inRange,
  belowTarget,
  low,
  veryLowGlucose,
  aboveTarget,
  veryHighGlucose,
  elevatedPressure,
  highPressure,
  veryHighPressure,
  severePressure,
}

sealed class VitalReading {
  const VitalReading(this.measuredAt, {this.isSample = false});

  final DateTime measuredAt;
  final bool isSample;
  ReadingStatus get status;
}

class GlucoseReading extends VitalReading {
  const GlucoseReading(
    super.measuredAt,
    this.value,
    this.timing, {
    super.isSample,
  });

  final int value;
  final MealTiming timing;

  // General CDC targets for nonpregnant adults with diabetes.
  @override
  ReadingStatus get status {
    if (value < 55) return ReadingStatus.veryLowGlucose;
    if (value < 70) return ReadingStatus.low;
    if (value >= 300) return ReadingStatus.veryHighGlucose;
    if (timing == MealTiming.beforeMeal) {
      if (value < 80) return ReadingStatus.belowTarget;
      return value <= 130 ? ReadingStatus.inRange : ReadingStatus.aboveTarget;
    }
    return value < 180 ? ReadingStatus.inRange : ReadingStatus.aboveTarget;
  }
}

class PressureReading extends VitalReading {
  const PressureReading(
    super.measuredAt,
    this.systolic,
    this.diastolic, {
    super.isSample,
  });

  final int systolic;
  final int diastolic;

  // American Heart Association adult blood pressure categories.
  @override
  ReadingStatus get status {
    if (systolic > 180 || diastolic > 120) return ReadingStatus.severePressure;
    if (systolic >= 140 || diastolic >= 90) {
      return ReadingStatus.veryHighPressure;
    }
    if (systolic >= 130 || diastolic >= 80) return ReadingStatus.highPressure;
    if (systolic < 90 || diastolic < 60) return ReadingStatus.low;
    return systolic >= 120
        ? ReadingStatus.elevatedPressure
        : ReadingStatus.inRange;
  }
}

class ReadingComparison {
  const ReadingComparison(this.current, this.previous);

  final VitalReading current;
  final VitalReading? previous;
}
