import 'vital_reading.dart';

const checkInHistoryLimit = 30;

List<T> appendReading<T>(List<T> readings, T reading) => List.unmodifiable([
  ...readings.skip(
    (readings.length - checkInHistoryLimit + 1).clamp(0, readings.length),
  ),
  reading,
]);

class CheckInHistory {
  const CheckInHistory({
    this.conditions = const {},
    this.glucose = const [],
    this.pressure = const [],
  });

  final Set<TrackedCondition> conditions;
  final List<GlucoseReading> glucose;
  final List<PressureReading> pressure;

  Iterable<GlucoseReading> glucoseAt(MealTiming timing) =>
      glucose.where((reading) => reading.timing == timing);

  CheckInHistory copyWith({
    Set<TrackedCondition>? conditions,
    List<GlucoseReading>? glucose,
    List<PressureReading>? pressure,
  }) => CheckInHistory(
    conditions: conditions ?? this.conditions,
    glucose: glucose ?? this.glucose,
    pressure: pressure ?? this.pressure,
  );
}

abstract interface class CheckInStore {
  Future<CheckInHistory?> load(String accountId);
  Future<void> save(String accountId, CheckInHistory history);
}
