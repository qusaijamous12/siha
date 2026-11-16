import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_app/core/storage/local_check_in_store.dart';
import 'package:medicine_app/feature/check_in/model/check_in_history.dart';
import 'package:medicine_app/feature/check_in/model/reading_change.dart';
import 'package:medicine_app/feature/check_in/model/vital_reading.dart';

void main() {
  test('Preserves single-reading records from an older install', () async {
    const account = 'person@example.test';
    final key = 'check-in.v1.${sha256.convert(utf8.encode(account))}';
    final now = DateTime(2026, 11, 16, 9);
    FlutterSecureStorage.setMockInitialValues({
      key: jsonEncode({
        'conditions': ['diabetes', 'hypertension'],
        'glucose': {
          'beforeMeal': {
            'at': now.millisecondsSinceEpoch,
            'value': 152,
            'sample': false,
          },
        },
        'pressure': {
          'at': now.millisecondsSinceEpoch,
          'systolic': 131,
          'diastolic': 83,
          'sample': false,
        },
      }),
    });

    const store = LocalCheckInStore(FlutterSecureStorage());
    final saved = (await store.load(account))!;
    expect(saved.pressure.single.systolic, 131);
    expect(saved.glucoseAt(MealTiming.beforeMeal).single.value, 152);
    final next = GlucoseReading(
      now.add(const Duration(days: 1)),
      114,
      MealTiming.beforeMeal,
    );
    await store.save(
      account,
      saved.copyWith(glucose: appendReading(saved.glucose, next)),
    );

    final restored = (await store.load(account))!;
    expect(restored.glucose.map((entry) => entry.value), [152, 114]);
    expect(restored.pressure.single.diastolic, 83);
    expect(await store.load('another@example.test'), isNull);
  });

  test('Uses demo thresholds on comparable readings in either direction', () {
    final now = DateTime(2026, 11, 16);
    final before = GlucoseReading(now, 130, MealTiming.beforeMeal);
    expect(ReadingChange.isLarge(before, null), isFalse);
    expect(
      ReadingChange.isLarge(
        before,
        GlucoseReading(now, 100, MealTiming.beforeMeal),
      ),
      isTrue,
    );
    expect(
      ReadingChange.isLarge(
        before,
        GlucoseReading(now, 100, MealTiming.twoHoursAfterMeal),
      ),
      isFalse,
    );
    expect(
      ReadingChange.isLarge(
        PressureReading(now, 120, 74),
        PressureReading(now, 128, 84),
      ),
      isTrue,
    );
  });
}
