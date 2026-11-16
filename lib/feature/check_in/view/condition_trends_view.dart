import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/care_widgets.dart';
import '../controller/check_in_controller.dart';
import '../model/vital_reading.dart';
import 'reading_change_notice.dart';
import 'reading_result_card.dart';
import 'trend_chart.dart';

class ConditionTrendsView extends StatefulWidget {
  const ConditionTrendsView({super.key});

  @override
  State<ConditionTrendsView> createState() => _ConditionTrendsViewState();
}

class _ConditionTrendsViewState extends State<ConditionTrendsView> {
  final _checkIn = Get.find<CheckInController>();
  String? _selection;
  MealTiming _timing = MealTiming.beforeMeal;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('trends_title'.tr)),
    body: SafeArea(
      top: false,
      child: Obx(() {
        final history = _checkIn.history.value;
        final busy = _checkIn.busy.value;
        if (history == null) {
          return CareList(
            children: [
              if (busy)
                const Center(child: CircularProgressIndicator())
              else
                EmptyCard(
                  Icons.info_outline_rounded,
                  'check_in_load_error'.tr,
                  action: 'check_in_retry'.tr,
                  onTap: _checkIn.prepare,
                ),
            ],
          );
        }

        final options = {
          if (history.glucose.isNotEmpty ||
              history.conditions.contains(TrackedCondition.diabetes))
            'glucose': 'check_in_glucose'.tr,
          if (history.pressure.isNotEmpty ||
              history.conditions.contains(TrackedCondition.hypertension))
            'pressure': 'check_in_pressure'.tr,
        };
        final selected = options.containsKey(_selection)
            ? _selection!
            : options.keys.firstOrNull;

        return CareList(
          key: ValueKey(selected),
          children: [
            PageIntro('trends_heading'.tr, 'trends_intro'.tr),
            const SizedBox(height: 16),
            if (options.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final option in options.entries)
                    ChoiceChip(
                      label: Text(option.value),
                      selected: selected == option.key,
                      onSelected: (_) =>
                          setState(() => _selection = option.key),
                    ),
                ],
              ),
            const SizedBox(height: 10),
            FilledButton.icon(
              onPressed: busy ? null : _checkIn.requestPrompt,
              icon: const Icon(Icons.add_rounded),
              label: Text('trends_log_reading'.tr),
            ),
            const SizedBox(height: 12),
            if (selected == 'glucose') ...[
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final timing in MealTiming.values)
                    ChoiceChip(
                      label: Text(timing.labelKey.tr),
                      selected: _timing == timing,
                      onSelected: (_) => setState(() => _timing = timing),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              _vitals(history.glucoseAt(_timing).toList(), [
                'check_in_glucose'.tr,
              ], 'check_in_mg'),
            ] else if (selected == 'pressure')
              _vitals(history.pressure, [
                'trends_systolic'.tr,
                'trends_diastolic'.tr,
              ], 'check_in_mmhg')
            else
              EmptyCard(Icons.show_chart_rounded, 'trends_empty'.tr),
          ],
        );
      }),
    ),
  );

  Widget _vitals(
    List<VitalReading> readings,
    List<String> labels,
    String unit,
  ) {
    final change = readings.length < 2
        ? null
        : vitalChangeLabel(
            context,
            ReadingComparison(readings.last, readings[readings.length - 2]),
          );
    return _SeriesCard(
      labels: labels,
      unit: unit.tr,
      change: change,
      points: [
        for (final reading in readings)
          TrendPoint(reading.measuredAt, switch (reading) {
            GlucoseReading(:final value) => [value],
            PressureReading(:final systolic, :final diastolic) => [
              systolic,
              diastolic,
            ],
          }, isSample: reading.isSample),
      ],
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({
    required this.labels,
    required this.unit,
    required this.points,
    this.change,
  });

  final List<String> labels;
  final String unit;
  final List<TrendPoint> points;
  final String? change;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return EmptyCard(Icons.show_chart_rounded, 'trends_no_readings'.tr);
    }
    final formats = MaterialLocalizations.of(context);
    final latest = points.last;
    String value(TrendPoint point) {
      final numbers = point.values.map(formats.formatDecimal).join(' / ');
      return '\u2066$numbers\u2069 $unit';
    }

    return CareCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'trends_latest'.tr,
            style: const TextStyle(color: AppColors.muted),
          ),
          Text(value(latest), style: Theme.of(context).textTheme.headlineSmall),
          if (change != null) ...[
            const SizedBox(height: 10),
            ReadingChangeNotice(change: change),
          ],
          const SizedBox(height: 14),
          TrendChart(points: points, labels: labels),
          if (points.any((point) => point.isSample)) ...[
            const SizedBox(height: 8),
            Text(
              'trends_sample_note'.tr,
              style: const TextStyle(color: AppColors.muted),
            ),
          ],
          const Divider(height: 24),
          Text(
            'trends_recent'.tr,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          for (final point in points.reversed.take(5))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "${formats.formatMediumDate(point.at)} · ${TimeOfDay.fromDateTime(point.at).format(context)} · "
                "${value(point)}"
                "${point.isSample ? ' · ${'trends_sample_point'.tr}' : ''}",
              ),
            ),
        ],
      ),
    );
  }
}
