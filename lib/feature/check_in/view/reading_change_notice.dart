import 'package:get/get.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../model/reading_change.dart';
import '../model/vital_reading.dart';

class ReadingChangeNotice extends StatelessWidget {
  const ReadingChangeNotice({super.key, this.change});

  final String? change;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.amber,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: AppColors.rust,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'trends_change_title'.tr,
                  style: const TextStyle(
                    color: AppColors.rust,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (change != null)
                  Text(change!, style: const TextStyle(color: AppColors.rust)),
                Text(
                  'trends_change_note'.tr,
                  style: const TextStyle(color: AppColors.rust, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String changeLabel(BuildContext context, String label, int delta, String unit) {
  final key = delta == 0
      ? 'unchanged'
      : delta > 0
      ? 'increased'
      : 'decreased';
  return 'check_in_$key'.trParams({
    'label': label.tr,
    'delta': MaterialLocalizations.of(context).formatDecimal(delta.abs()),
    'unit': unit.tr,
  });
}

String? vitalChangeLabel(BuildContext context, ReadingComparison result) {
  final current = result.current;
  final previous = result.previous;
  if (!ReadingChange.isLarge(current, previous)) return null;

  return switch ((current, previous)) {
    (GlucoseReading a, GlucoseReading b) => changeLabel(
      context,
      'check_in_glucose',
      a.value - b.value,
      'check_in_mg',
    ),
    (PressureReading a, PressureReading b) => [
      changeLabel(
        context,
        'trends_systolic',
        a.systolic - b.systolic,
        'check_in_mmhg',
      ),
      changeLabel(
        context,
        'trends_diastolic',
        a.diastolic - b.diastolic,
        'check_in_mmhg',
      ),
    ].join('\n'),
    _ => null,
  };
}
