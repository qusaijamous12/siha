enum RecordKind { condition, medicine }

class HealthRecord {
  const HealthRecord({
    required this.id,
    required this.kind,
    required this.name,
    this.details = '',
    this.reminder,
    this.isSample = false,
  });

  final String id;
  final RecordKind kind;
  final String name;
  final String details;
  final DailyReminder? reminder;
  final bool isSample;
}

class DailyReminder {
  const DailyReminder({required this.minuteOfDay, this.action = ''});

  final int minuteOfDay;
  final String action;

  DateTime on(DateTime day) => DateTime(
    day.year,
    day.month,
    day.day,
    minuteOfDay ~/ 60,
    minuteOfDay % 60,
  );
}

enum ReminderStatus { upcoming, due, done }

class ScheduledTask {
  const ScheduledTask(this.record, this.time, this.status);

  final HealthRecord record;
  final DateTime time;
  final ReminderStatus status;
}

abstract interface class HealthGateway {
  List<HealthRecord> healthRecords(String accountId);
  void saveHealthRecord(String accountId, HealthRecord record);
  void deleteHealthRecord(String accountId, String recordId);
  Set<String> completedTasks(String accountId, DateTime day);
  void setCompleted(String accountId, String recordId, DateTime day, bool done);
}
