import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../controller/check_in_controller.dart';
import '../model/vital_reading.dart';
import 'reading_result_card.dart';

class CheckInView extends StatefulWidget {
  const CheckInView({super.key});

  @override
  State<CheckInView> createState() => _CheckInViewState();
}

class _CheckInViewState extends State<CheckInView> {
  final _checkIn = Get.find<CheckInController>();
  final _form = GlobalKey<FormState>();
  final _glucose = TextEditingController();
  final _systolic = TextEditingController();
  final _diastolic = TextEditingController();
  var _timing = MealTiming.beforeMeal;

  @override
  void dispose() {
    _glucose.dispose();
    _systolic.dispose();
    _diastolic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final busy = _checkIn.busy.value;
    final results = _checkIn.comparison.toList()
      ..sort(
        (a, b) =>
            _priority(b.current.status).compareTo(_priority(a.current.status)),
      );
    final hasResults = results.isNotEmpty;
    final ready = _checkIn.ready.value;
    final error = _checkIn.error.value;
    final trackGlucose = _checkIn.conditions.contains(
      TrackedCondition.diabetes,
    );
    final trackPressure = _checkIn.conditions.contains(
      TrackedCondition.hypertension,
    );

    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('check_in_title'.tr),
        ),
        body: SafeArea(
          top: false,
          child: CareList(
            key: ValueKey(hasResults),
            children: [
              if (hasResults) ...[
                PageIntro('check_in_results'.tr, 'check_in_saved'.tr),
                const SizedBox(height: 14),
                for (final result in results) ...[
                  ReadingResultCard(result),
                  const SizedBox(height: 12),
                ],
                Text(
                  'check_in_reference_note'.tr,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ] else if (ready) ...[
                _buildForm(busy, error, trackGlucose, trackPressure),
              ] else if (busy || error == null) ...[
                const Center(child: CircularProgressIndicator()),
              ] else ...[
                EmptyCard(Icons.info_outline_rounded, error.tr),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _checkIn.prepare,
                  child: Text('check_in_retry'.tr),
                ),
              ],
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Center(
            heightFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 660),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasResults)
                      FilledButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('check_in_continue'.tr),
                      )
                    else ...[
                      if (ready && (trackGlucose || trackPressure))
                        FilledButton(
                          onPressed: busy
                              ? null
                              : () => _save(trackGlucose, trackPressure),
                          child: Text('check_in_save'.tr),
                        ),
                      TextButton(
                        onPressed: busy ? null : _skip,
                        child: Text('check_in_skip'.tr),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  });

  Widget _buildForm(
    bool busy,
    String? error,
    bool trackGlucose,
    bool trackPressure,
  ) {
    return Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: CareIcon(Icons.monitor_heart_outlined, size: 52),
          ),
          const SizedBox(height: 10),
          PageIntro('check_in_heading'.tr, 'check_in_select'.tr),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              FilterChip(
                label: Text('check_in_diabetes'.tr),
                selected: trackGlucose,
                onSelected: busy
                    ? null
                    : (value) => _checkIn.setCondition(
                        TrackedCondition.diabetes,
                        value,
                      ),
              ),
              FilterChip(
                label: Text('check_in_hypertension'.tr),
                selected: trackPressure,
                onSelected: busy
                    ? null
                    : (value) => _checkIn.setCondition(
                        TrackedCondition.hypertension,
                        value,
                      ),
              ),
            ],
          ),
          if (trackGlucose || trackPressure) ...[
            const SizedBox(height: 12),
            Text(
              'check_in_enter'.tr,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
          if (trackGlucose) ...[
            const SizedBox(height: 14),
            CareCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle('check_in_glucose'.tr),
                  const SizedBox(height: 10),
                  _numberField(
                    _glucose,
                    'check_in_glucose_value',
                    'check_in_mg',
                    busy,
                  ),
                  const SizedBox(height: 10),
                  Text('check_in_timing'.tr),
                  const SizedBox(height: 3),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      for (final timing in MealTiming.values)
                        ChoiceChip(
                          label: Text(timing.labelKey.tr),
                          selected: _timing == timing,
                          onSelected: busy
                              ? null
                              : (_) => setState(() => _timing = timing),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
          if (trackPressure) ...[
            const SizedBox(height: 12),
            CareCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle('check_in_pressure'.tr),
                  const SizedBox(height: 10),
                  _numberField(
                    _systolic,
                    'check_in_systolic',
                    'check_in_mmhg',
                    busy,
                    pairedWith: _diastolic,
                  ),
                  const SizedBox(height: 8),
                  _numberField(
                    _diastolic,
                    'check_in_diastolic',
                    'check_in_mmhg',
                    busy,
                    pairedWith: _systolic,
                    validateOrder: true,
                  ),
                ],
              ),
            ),
          ],
          if (error != null) ...[
            const SizedBox(height: 10),
            Semantics(
              liveRegion: true,
              child: Text(
                error.tr,
                style: const TextStyle(color: AppColors.red),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _numberField(
    TextEditingController input,
    String label,
    String unit,
    bool busy, {
    TextEditingController? pairedWith,
    bool validateOrder = false,
  }) => TextFormField(
    controller: input,
    enabled: !busy,
    keyboardType: TextInputType.number,
    onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
    textDirection: TextDirection.ltr,
    decoration: InputDecoration(labelText: label.tr, suffixText: unit.tr),
    validator: (value) {
      if (input.text.trim().isEmpty) {
        return pairedWith != null && pairedWith.text.trim().isNotEmpty
            ? 'required'.tr
            : null;
      }
      final number = _parse(input.text);
      if (number == null) return 'check_in_number_error'.tr;
      final upper = validateOrder ? _parse(pairedWith!.text) : null;
      if (upper != null && upper <= number) return 'check_in_pressure_order'.tr;
      return null;
    },
  );

  int? _parse(String input) {
    final normalized = input.trim().replaceAllMapped(RegExp('[٠-٩۰-۹]'), (
      match,
    ) {
      final code = match[0]!.codeUnitAt(0);
      return (code >= 0x06F0 ? code - 0x06F0 : code - 0x0660).toString();
    });
    if (!RegExp(r'^[0-9]{1,4}$').hasMatch(normalized)) return null;
    final value = int.parse(normalized);
    return value > 0 ? value : null;
  }

  Future<void> _save(bool trackGlucose, bool trackPressure) async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await _checkIn.submit(
      timing: _timing,
      glucose: trackGlucose ? _parse(_glucose.text) : null,
      systolic: trackPressure ? _parse(_systolic.text) : null,
      diastolic: trackPressure ? _parse(_diastolic.text) : null,
    );
  }

  Future<void> _skip() async {
    if (await _checkIn.skip() && mounted) Navigator.pop(context);
  }

  int _priority(ReadingStatus status) => switch (status) {
    ReadingStatus.severePressure ||
    ReadingStatus.veryLowGlucose ||
    ReadingStatus.veryHighGlucose => 2,
    ReadingStatus.inRange => 0,
    _ => 1,
  };
}
