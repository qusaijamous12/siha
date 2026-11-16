import 'vital_reading.dart';

/// Prototype thresholds for calling attention to a change between entries.
abstract final class ReadingChange {
  static const glucoseThreshold = 30;
  static const systolicThreshold = 20;
  static const diastolicThreshold = 10;

  static bool isLarge(VitalReading current, VitalReading? previous) =>
      switch ((current, previous)) {
        (GlucoseReading a, GlucoseReading b) =>
          a.timing == b.timing && (a.value - b.value).abs() >= glucoseThreshold,
        (PressureReading a, PressureReading b) =>
          (a.systolic - b.systolic).abs() >= systolicThreshold ||
              (a.diastolic - b.diastolic).abs() >= diastolicThreshold,
        _ => false,
      };
}
