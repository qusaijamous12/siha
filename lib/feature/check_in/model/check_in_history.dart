import 'vital_reading.dart';

class CheckInHistory {
  const CheckInHistory({
    this.conditions = const {},
    this.glucose = const {},
    this.pressure,
  });

  final Set<TrackedCondition> conditions;
  final Map<MealTiming, GlucoseReading> glucose;
  final PressureReading? pressure;
}

abstract interface class CheckInStore {
  Future<CheckInHistory?> load(String accountId);
  Future<void> save(String accountId, CheckInHistory history);
}
