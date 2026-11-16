import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../feature/check_in/model/check_in_history.dart';
import '../../feature/check_in/model/vital_reading.dart';

class LocalCheckInStore implements CheckInStore {
  const LocalCheckInStore(this._storage);

  final FlutterSecureStorage _storage;

  String _key(String accountId) =>
      'check-in.v1.${sha256.convert(utf8.encode(accountId))}';

  @override
  Future<CheckInHistory?> load(String accountId) async {
    final saved = await _storage.read(key: _key(accountId));
    if (saved == null) return null;
    final json = jsonDecode(saved) as Map<String, dynamic>;
    final conditions = json['conditions'] as List<dynamic>;
    final glucose = json['glucose'] as Map<String, dynamic>;
    return CheckInHistory(
      conditions: TrackedCondition.values
          .where((condition) => conditions.contains(condition.name))
          .toSet(),
      glucose: [
        for (final timing in MealTiming.values)
          for (final reading in _savedReadings(glucose[timing.name]))
            GlucoseReading(
              _date(reading),
              reading['value'] as int,
              timing,
              isSample: reading['sample'] as bool? ?? false,
            ),
      ],
      pressure: [
        for (final reading in _savedReadings(json['pressure']))
          PressureReading(
            _date(reading),
            reading['systolic'] as int,
            reading['diastolic'] as int,
            isSample: reading['sample'] as bool? ?? false,
          ),
      ],
    );
  }

  // Older installs kept one object per reading type. Keep it as the first point.
  Iterable<Map<String, dynamic>> _savedReadings(Object? value) =>
      switch (value) {
        final Map<String, dynamic> reading => [reading],
        final List<dynamic> readings => readings.cast<Map<String, dynamic>>(),
        _ => const [],
      };

  DateTime _date(Map<String, dynamic> reading) =>
      DateTime.fromMillisecondsSinceEpoch(reading['at'] as int);

  @override
  Future<void> save(String accountId, CheckInHistory history) => _storage.write(
    key: _key(accountId),
    value: jsonEncode({
      'conditions': history.conditions
          .map((condition) => condition.name)
          .toList(),
      'glucose': {
        for (final timing in MealTiming.values)
          timing.name: [
            for (final entry in history.glucoseAt(timing))
              {
                'at': entry.measuredAt.millisecondsSinceEpoch,
                'value': entry.value,
                'sample': entry.isSample,
              },
          ],
      },
      'pressure': [
        for (final entry in history.pressure)
          {
            'at': entry.measuredAt.millisecondsSinceEpoch,
            'systolic': entry.systolic,
            'diastolic': entry.diastolic,
            'sample': entry.isSample,
          },
      ],
    }),
  );
}
