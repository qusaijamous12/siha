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
    final pressure = json['pressure'] as Map<String, dynamic>?;
    return CheckInHistory(
      conditions: TrackedCondition.values
          .where((condition) => conditions.contains(condition.name))
          .toSet(),
      glucose: {
        for (final timing in MealTiming.values)
          if (glucose[timing.name] case {
            'at': int at,
            'value': int value,
            'sample': bool sample,
          })
            timing: GlucoseReading(
              DateTime.fromMillisecondsSinceEpoch(at),
              value,
              timing,
              isSample: sample,
            ),
      },
      pressure: pressure == null
          ? null
          : PressureReading(
              DateTime.fromMillisecondsSinceEpoch(pressure['at'] as int),
              pressure['systolic'] as int,
              pressure['diastolic'] as int,
              isSample: pressure['sample'] as bool,
            ),
    );
  }

  @override
  Future<void> save(String accountId, CheckInHistory history) => _storage.write(
    key: _key(accountId),
    value: jsonEncode({
      'conditions': history.conditions
          .map((condition) => condition.name)
          .toList(),
      'glucose': {
        for (final entry in history.glucose.entries)
          entry.key.name: {
            'at': entry.value.measuredAt.millisecondsSinceEpoch,
            'value': entry.value.value,
            'sample': entry.value.isSample,
          },
      },
      if (history.pressure case final pressure?)
        'pressure': {
          'at': pressure.measuredAt.millisecondsSinceEpoch,
          'systolic': pressure.systolic,
          'diastolic': pressure.diastolic,
          'sample': pressure.isSample,
        },
    }),
  );
}
