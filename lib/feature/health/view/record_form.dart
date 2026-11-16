import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';

import '../../../core/widgets/care_widgets.dart';
import '../controller/health_controller.dart';
import '../model/health_record.dart';

Future<void> showMedicineForm(BuildContext context, {HealthRecord? record}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 580),
      builder: (context) => _MedicineForm(record: record),
    );

class _MedicineForm extends StatefulWidget {
  const _MedicineForm({this.record});

  final HealthRecord? record;

  @override
  State<_MedicineForm> createState() => _MedicineFormState();
}

class _MedicineFormState extends State<_MedicineForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _details;
  late TimeOfDay _time;
  late bool _remind;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    final reminder = record?.reminder;
    final minutes = reminder?.minuteOfDay ?? 540;
    _time = TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);
    _remind = record == null || reminder != null;
    String initialText(String? value) => value == null || value.isEmpty
        ? ''
        : record!.isSample
        ? value.tr
        : value;
    _name = TextEditingController(text: initialText(record?.name));
    _details = TextEditingController(text: initialText(record?.details));
  }

  @override
  void dispose() {
    _name.dispose();
    _details.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.record == null ? 'add_medicine' : 'edit_medicine';
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        22,
        0,
        22,
        18 +
            MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title.tr, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: 'medicine_name'.tr),
              validator: requiredText,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _details,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: 'dose'.tr,
                hintText: 'dose_hint'.tr,
              ),
              validator: requiredText,
            ),
            SwitchListTile(
              title: Text('daily_reminder'.tr),
              contentPadding: EdgeInsets.zero,
              value: _remind,
              onChanged: (value) => setState(() => _remind = value),
            ),
            if (_remind) ...[
              CareCard(
                onTap: _pickTime,
                child: Row(
                  children: [
                    const Icon(Icons.schedule_rounded),
                    const SizedBox(width: 10),
                    Expanded(child: Text('reminder_time'.tr)),
                    Text(
                      _time.format(context),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(onPressed: _save, child: Text('save'.tr)),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final chosen = await showTimePicker(context: context, initialTime: _time);
    if (mounted && chosen != null) setState(() => _time = chosen);
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    Get.find<HealthController>().saveRecord(
      kind: RecordKind.medicine,
      name: _name.text,
      details: _details.text,
      reminder: _remind
          ? DailyReminder(minuteOfDay: _time.hour * 60 + _time.minute)
          : null,
      previous: widget.record,
    );
    Navigator.pop(context);
  }
}
