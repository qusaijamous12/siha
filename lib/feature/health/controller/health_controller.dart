import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';
import '../model/health_record.dart';

class HealthController extends GetxController with WidgetsBindingObserver {
  HealthController(this._gateway, this._auth, this._now);

  final HealthGateway _gateway;
  final AuthController _auth;
  final DateTime Function() _now;

  final records = <HealthRecord>[].obs;
  final tasks = <ScheduledTask>[].obs;
  final selectedKind = RecordKind.condition.obs;
  final _dismissed = <String>{};
  final foregroundAlert = Rxn<ScheduledTask>();

  late final Worker _session;
  Timer? _clock;
  DateTime? _day;
  var _nextId = 0;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _session = ever(_auth.account, (_) {
      selectedKind.value = RecordKind.condition;
      _dismissed.clear();
      _load();
      if (_auth.account.value == null) {
        _clock?.cancel();
      } else {
        _startClock();
      }
    });
  }

  void _startClock() {
    _clock?.cancel();
    const minute = Duration.microsecondsPerMinute;
    final elapsed = _now().microsecondsSinceEpoch % minute;
    _clock = Timer(Duration(microseconds: minute - elapsed), () {
      _refreshTasks();
      _startClock();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _auth.account.value != null) {
      _refreshTasks();
      _startClock();
    }
  }

  void _load() {
    final account = _auth.account.value;
    records.assignAll(
      account == null
          ? const <HealthRecord>[]
          : _gateway.healthRecords(account.id),
    );
    _refreshTasks();
  }

  void _refreshTasks() {
    final account = _auth.account.value;
    final now = _now();
    final day = DateTime(now.year, now.month, now.day);
    if (_day != day) {
      _day = day;
      _dismissed.clear();
    }

    final completed = account == null
        ? const <String>{}
        : _gateway.completedTasks(account.id, day);
    final schedule = <ScheduledTask>[];
    for (final record in records) {
      final reminder = record.reminder;
      if (reminder == null) continue;
      final time = reminder.on(day);
      final status = completed.contains(record.id)
          ? ReminderStatus.done
          : time.isAfter(now)
          ? ReminderStatus.upcoming
          : ReminderStatus.due;
      schedule.add(ScheduledTask(record, time, status));
    }
    schedule.sort((a, b) => a.time.compareTo(b.time));
    tasks.assignAll(schedule);
    foregroundAlert.value = schedule.firstWhereOrNull(
      (task) =>
          task.status == ReminderStatus.due &&
          !_dismissed.contains(task.record.id),
    );
  }

  void dismissAlert(ScheduledTask task) {
    _dismissed.add(task.record.id);
    _refreshTasks();
  }

  void saveRecord({
    required RecordKind kind,
    required String name,
    required String details,
    DailyReminder? reminder,
    HealthRecord? previous,
  }) {
    final account = _auth.account.value;
    if (account == null) return;
    final record = HealthRecord(
      id: previous?.id ?? 'record-${_nextId++}',
      kind: kind,
      name: name.trim(),
      details: details.trim(),
      reminder: reminder,
    );
    _dismissed.remove(record.id);
    _gateway.saveHealthRecord(account.id, record);
    _load();
  }

  void deleteRecord(HealthRecord record) {
    final account = _auth.account.value;
    if (account == null) return;
    _gateway.deleteHealthRecord(account.id, record.id);
    _load();
  }

  void toggleTask(ScheduledTask task) {
    final account = _auth.account.value;
    final now = _now();
    if (account == null ||
        now.year != task.time.year ||
        now.month != task.time.month ||
        now.day != task.time.day) {
      _refreshTasks();
      return;
    }
    _gateway.setCompleted(
      account.id,
      task.record.id,
      now,
      task.status != ReminderStatus.done,
    );
    _refreshTasks();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _session.dispose();
    _clock?.cancel();
    super.onClose();
  }
}
