import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';
import '../model/check_in_history.dart';
import '../model/vital_reading.dart';

class CheckInController extends GetxController with WidgetsBindingObserver {
  CheckInController(this._store, this._auth, this._now);

  final CheckInStore _store;
  final AuthController _auth;
  final DateTime Function() _now;

  final requested = false.obs;
  final busy = false.obs;
  final ready = false.obs;
  final conditions = <TrackedCondition>{}.obs;
  final comparison = <ReadingComparison>[].obs;
  final error = RxnString();

  late final Worker _session;
  final history = Rxn<CheckInHistory>();
  bool _wasHidden = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _session = ever(_auth.account, (_) {
      history.value = null;
      requestPrompt();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _wasHidden = true;
    } else if (state == AppLifecycleState.resumed && _wasHidden) {
      _wasHidden = false;
      requestPrompt();
    }
  }

  void requestPrompt() {
    if (_auth.account.value != null) requested.value = true;
  }

  void finishPrompt() => requested.value = false;

  Future<void> prepare() async {
    final account = _auth.account.value;
    if (account == null || busy.value) return;
    ready.value = false;
    comparison.clear();
    conditions.clear();
    error.value = null;
    busy.value = true;
    try {
      final saved =
          history.value ??
          await _store.load(account.id) ??
          (account.isDemo ? _sampleHistory() : const CheckInHistory());
      if (isClosed || _auth.account.value != account) return;
      history.value = saved;
      conditions.assignAll(saved.conditions);
      ready.value = true;
    } on Exception {
      if (!isClosed) error.value = 'check_in_load_error';
    } finally {
      if (!isClosed) busy.value = false;
    }
  }

  CheckInHistory _sampleHistory() {
    final now = _now();
    const before = [126, 138, 130, 145];
    const after = [160, 171, 157, 165];
    const upper = [128, 141, 132, 136];
    const lower = [80, 89, 82, 86];
    DateTime day(int index) =>
        DateTime(now.year, now.month, now.day - 4 + index, 8);
    return CheckInHistory(
      conditions: TrackedCondition.values.toSet(),
      glucose: [
        for (var i = 0; i < before.length; i++) ...[
          GlucoseReading(
            day(i),
            before[i],
            MealTiming.beforeMeal,
            isSample: true,
          ),
          GlucoseReading(
            day(i).add(const Duration(hours: 2)),
            after[i],
            MealTiming.twoHoursAfterMeal,
            isSample: true,
          ),
        ],
      ],
      pressure: [
        for (var i = 0; i < upper.length; i++)
          PressureReading(day(i), upper[i], lower[i], isSample: true),
      ],
    );
  }

  void setCondition(TrackedCondition condition, bool selected) {
    if (selected) {
      conditions.add(condition);
    } else {
      conditions.remove(condition);
    }
    error.value = null;
  }

  Future<void> submit({
    required MealTiming timing,
    int? glucose,
    int? systolic,
    int? diastolic,
  }) async {
    if (busy.value || !ready.value || comparison.isNotEmpty) return;
    if (glucose == null && systolic == null) {
      error.value = 'check_in_required_reading';
      return;
    }
    final now = _now();
    final glucoseReading = glucose == null
        ? null
        : GlucoseReading(now, glucose, timing);
    final pressureReading = systolic == null || diastolic == null
        ? null
        : PressureReading(now, systolic, diastolic);
    final saved = history.value!;
    final sameTiming = saved.glucoseAt(timing).toList();
    final next = saved.copyWith(
      conditions: conditions.toSet(),
      glucose: glucoseReading == null
          ? null
          : [
              ...saved.glucose.where((reading) => reading.timing != timing),
              ...appendReading(sameTiming, glucoseReading),
            ],
      pressure: pressureReading == null
          ? null
          : appendReading(saved.pressure, pressureReading),
    );
    if (await _save(next) && !isClosed) {
      comparison.assignAll([
        if (glucoseReading != null)
          ReadingComparison(glucoseReading, sameTiming.lastOrNull),
        if (pressureReading != null)
          ReadingComparison(pressureReading, saved.pressure.lastOrNull),
      ]);
    }
  }

  bool get hasConditionChanges {
    final saved = history.value?.conditions;
    return saved != null &&
        (saved.length != conditions.length || !saved.containsAll(conditions));
  }

  Future<bool> skip() async {
    if (busy.value) return false;
    if (!hasConditionChanges) return true;
    return _save(history.value!.copyWith(conditions: conditions.toSet()));
  }

  Future<bool> _save(CheckInHistory next) async {
    final account = _auth.account.value;
    if (account == null || busy.value) return false;
    busy.value = true;
    error.value = null;
    try {
      await _store.save(account.id, next);
      if (isClosed || _auth.account.value != account) return false;
      history.value = next;
      return true;
    } on Exception {
      if (!isClosed) error.value = 'check_in_save_error';
      return false;
    } finally {
      if (!isClosed) busy.value = false;
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _session.dispose();
    super.onClose();
  }
}
