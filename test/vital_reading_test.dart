import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_app/feature/check_in/model/vital_reading.dart';

void main() {
  final now = DateTime(2026, 11, 14);

  test('Glucose classification distinguishes meal timing and low readings', () {
    ReadingStatus before(int value) =>
        GlucoseReading(now, value, MealTiming.beforeMeal).status;
    ReadingStatus after(int value) =>
        GlucoseReading(now, value, MealTiming.twoHoursAfterMeal).status;

    expect(before(54), ReadingStatus.veryLowGlucose);
    expect(after(55), ReadingStatus.low);
    expect(after(69), ReadingStatus.low);
    expect(before(70), ReadingStatus.belowTarget);
    expect(before(79), ReadingStatus.belowTarget);
    expect(before(80), ReadingStatus.inRange);
    expect(before(130), ReadingStatus.inRange);
    expect(before(131), ReadingStatus.aboveTarget);
    expect(after(179), ReadingStatus.inRange);
    expect(after(180), ReadingStatus.aboveTarget);
    expect(after(300), ReadingStatus.veryHighGlucose);
  });

  test('Blood pressure classification uses both measurements', () {
    ReadingStatus pressure(int top, int bottom) =>
        PressureReading(now, top, bottom).status;

    expect(pressure(89, 59), ReadingStatus.low);
    expect(pressure(90, 60), ReadingStatus.inRange);
    expect(pressure(119, 79), ReadingStatus.inRange);
    expect(pressure(120, 79), ReadingStatus.elevatedPressure);
    expect(pressure(120, 80), ReadingStatus.highPressure);
    expect(pressure(130, 58), ReadingStatus.highPressure);
    expect(pressure(139, 90), ReadingStatus.veryHighPressure);
    expect(pressure(180, 120), ReadingStatus.veryHighPressure);
    expect(pressure(181, 70), ReadingStatus.severePressure);
    expect(pressure(175, 121), ReadingStatus.severePressure);
  });
}
