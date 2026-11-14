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
  CheckInHistory? _history;
  bool _wasHidden = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _session = ever(_auth.account, (_) => requestPrompt());
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
    _history = null;
    error.value = null;
    busy.value = true;
    try {
      final history =
          await _store.load(account.id) ??
          (account.isDemo ? _sampleHistory() : const CheckInHistory());
      if (isClosed) return;
      _history = history;
      conditions.assignAll(history.conditions);
      ready.value = true;
    } on Exception {
      if (!isClosed) error.value = 'check_in_load_error';
    } finally {
      if (!isClosed) busy.value = false;
    }
  }

  CheckInHistory _sampleHistory() {
    final yesterday = _now().subtract(const Duration(days: 1));
    return CheckInHistory(
      conditions: TrackedCondition.values.toSet(),
      glucose: {
        MealTiming.beforeMeal: GlucoseReading(
          yesterday,
          145,
          MealTiming.beforeMeal,
          isSample: true,
        ),
        MealTiming.twoHoursAfterMeal: GlucoseReading(
          yesterday,
          165,
          MealTiming.twoHoursAfterMeal,
          isSample: true,
        ),
      },
      pressure: PressureReading(yesterday, 136, 86, isSample: true),
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
    final history = _history!;
    final next = CheckInHistory(
      conditions: conditions.toSet(),
      glucose: {...history.glucose, timing: ?glucoseReading},
      pressure: pressureReading ?? history.pressure,
    );
    if (await _save(next) && !isClosed) {
      comparison.assignAll([
        if (glucoseReading != null)
          ReadingComparison(glucoseReading, history.glucose[timing]),
        if (pressureReading != null)
          ReadingComparison(pressureReading, history.pressure),
      ]);
    }
  }

  Future<bool> skip() async {
    if (busy.value) return false;
    final history = _history;
    if (history == null ||
        (history.conditions.length == conditions.length &&
            history.conditions.containsAll(conditions))) {
      return true;
    }
    return _save(
      CheckInHistory(
        conditions: conditions.toSet(),
        glucose: history.glucose,
        pressure: history.pressure,
      ),
    );
  }

  Future<bool> _save(CheckInHistory history) async {
    final account = _auth.account.value;
    if (account == null || busy.value) return false;
    busy.value = true;
    error.value = null;
    try {
      await _store.save(account.id, history);
      if (isClosed) return false;
      _history = history;
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
