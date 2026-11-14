import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../model/vital_reading.dart';

extension MealTimingText on MealTiming {
  String get labelKey => switch (this) {
    MealTiming.beforeMeal => 'check_in_before_meal',
    MealTiming.twoHoursAfterMeal => 'check_in_after_meal',
  };
}

class ReadingResultCard extends StatelessWidget {
  const ReadingResultCard(this.result, {super.key});

  final ReadingComparison result;

  @override
  Widget build(BuildContext context) {
    final reading = result.current;
    final previous = result.previous;
    final status = reading.status;
    final key = switch (status) {
      ReadingStatus.inRange => 'in_range',
      ReadingStatus.belowTarget => 'below_target',
      ReadingStatus.low => 'low',
      ReadingStatus.veryLowGlucose => 'very_low_glucose',
      ReadingStatus.aboveTarget => 'above_target',
      ReadingStatus.veryHighGlucose => 'very_high_glucose',
      ReadingStatus.elevatedPressure => 'elevated_pressure',
      ReadingStatus.highPressure => 'high_pressure',
      ReadingStatus.veryHighPressure => 'very_high_pressure',
      ReadingStatus.severePressure => 'severe_pressure',
    };
    final (background, foreground) = switch (status) {
      ReadingStatus.inRange => (AppColors.mint, AppColors.forest),
      ReadingStatus.severePressure ||
      ReadingStatus.veryLowGlucose ||
      ReadingStatus.veryHighGlucose => (const Color(0xFFFCE4E6), AppColors.red),
      _ => (AppColors.amber, AppColors.rust),
    };
    final glucose = reading is GlucoseReading;
    final detailsKey = switch ((status, glucose)) {
      (ReadingStatus.veryLowGlucose, _) => 'check_in_very_low_glucose_note',
      (ReadingStatus.veryHighGlucose, _) => 'check_in_very_high_glucose_note',
      (ReadingStatus.severePressure, _) => 'check_in_severe_pressure_note',
      (ReadingStatus.low, true) => 'check_in_low_glucose_note',
      (ReadingStatus.low, false) => 'check_in_low_pressure_note',
      _ => null,
    };
    final formats = MaterialLocalizations.of(context);

    return CareCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CareIcon(
                glucose
                    ? Icons.water_drop_outlined
                    : Icons.monitor_heart_outlined,
                size: 39,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  (glucose ? 'check_in_glucose' : 'check_in_pressure').tr,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          if (reading case GlucoseReading(:final timing)) ...[
            const SizedBox(height: 6),
            Text(
              timing.labelKey.tr,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            _value(context, reading),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 7),
          StatusPill(
            'check_in_status_$key'.tr,
            background: background,
            color: foreground,
          ),
          if (detailsKey != null) ...[
            const SizedBox(height: 8),
            Text(
              detailsKey.tr,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 10),
          const Divider(),
          if (previous == null)
            Text('check_in_first_reading'.tr)
          else ...[
            Text(
              (previous.isSample
                      ? 'check_in_previous_sample'
                      : 'check_in_previous')
                  .trParams({
                    'value': _value(context, previous),
                    'date': formats.formatShortDate(previous.measuredAt),
                    'time': TimeOfDay.fromDateTime(previous.measuredAt)
                        .format(context),
                  }),
              style: const TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 7),
            switch ((reading, previous)) {
              (GlucoseReading current, GlucoseReading prior) => _change(
                context,
                'check_in_glucose',
                current.value - prior.value,
                'check_in_mg',
              ),
              (PressureReading current, PressureReading prior) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _change(
                    context,
                    'check_in_systolic',
                    current.systolic - prior.systolic,
                    'check_in_mmhg',
                  ),
                  _change(
                    context,
                    'check_in_diastolic',
                    current.diastolic - prior.diastolic,
                    'check_in_mmhg',
                  ),
                ],
              ),
              _ => const SizedBox.shrink(),
            },
          ],
        ],
      ),
    );
  }

  String _value(BuildContext context, VitalReading reading) {
    final format = MaterialLocalizations.of(context).formatDecimal;
    return switch (reading) {
      GlucoseReading(:final value) => '${format(value)} ${'check_in_mg'.tr}',
      PressureReading(:final systolic, :final diastolic) =>
        '\u2066${format(systolic)}/${format(diastolic)}\u2069 ${'check_in_mmhg'.tr}',
    };
  }

  Widget _change(BuildContext context, String label, int delta, String unit) {
    final key = delta == 0
        ? 'unchanged'
        : delta > 0
        ? 'increased'
        : 'decreased';
    return Text(
      'check_in_$key'.trParams({
        'label': label.tr,
        'delta': MaterialLocalizations.of(context).formatDecimal(delta.abs()),
        'unit': unit.tr,
      }),
    );
  }
}
