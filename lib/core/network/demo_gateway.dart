import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../feature/auth/model/account.dart';
import '../../feature/chat/model/chat_message.dart';
import '../../feature/doctors/model/doctor.dart';
import '../../feature/health/model/health_record.dart';

/// In-memory implementation of the feature data contracts for the prototype.
class DemoGateway
    implements AuthGateway, HealthGateway, DoctorsGateway, ChatGateway {
  DemoGateway(DateTime now) {
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 10);
    _visits[Account.demo.id] = [
      Appointment(doctor: doctors.first, time: tomorrow),
    ];
    startConversation(Account.demo.id, doctors.first.id, now);
    setCompleted(Account.demo.id, 'morning', now, true);
  }

  final _accounts =
      <String, ({Account account, String salt, Digest password})>{};
  final _records = <String, Map<String, HealthRecord>>{
    Account.demo.id: {for (final record in _sampleRecords) record.id: record},
  };
  final _completion = <String, Map<DateTime, Set<String>>>{};
  final _visits = <String, List<Appointment>>{};
  final _chat = <String, Map<String, List<ChatMessage>>>{};

  static const _sampleRecords = [
    HealthRecord(
      id: 'morning',
      kind: RecordKind.medicine,
      name: 'demo_med_1',
      details: 'dose_hint',
      reminder: DailyReminder(minuteOfDay: 480),
      isSample: true,
    ),
    HealthRecord(
      id: 'evening',
      kind: RecordKind.medicine,
      name: 'demo_med_2',
      details: 'dose_hint',
      reminder: DailyReminder(minuteOfDay: 1200),
      isSample: true,
    ),
    HealthRecord(
      id: 'allergies',
      kind: RecordKind.condition,
      name: 'demo_condition',
      reminder: DailyReminder(minuteOfDay: 750, action: 'demo_action'),
      isSample: true,
    ),
  ];

  @override
  final doctors = const [
    Doctor(
      id: 'lina',
      specialty: Specialty.family,
      initials: 'LH',
      arabicInitials: 'لح',
      slotMinutes: [600, 690, 840],
    ),
    Doctor(
      id: 'omar',
      specialty: Specialty.cardiology,
      initials: 'OK',
      arabicInitials: 'وع',
      slotMinutes: [570, 720, 930],
    ),
    Doctor(
      id: 'sara',
      specialty: Specialty.dermatology,
      initials: 'SN',
      arabicInitials: 'سن',
      slotMinutes: [630, 780, 960],
    ),
  ];

  @override
  Account? register(String name, String email, String password) {
    if (_accounts.containsKey(email)) return null;
    final account = Account(id: email, name: name, email: email);
    final random = Random.secure();
    final salt = base64Url.encode(
      List<int>.generate(16, (_) => random.nextInt(256)),
    );
    _accounts[email] = (
      account: account,
      salt: salt,
      password: _digest(salt, password),
    );
    return account;
  }

  @override
  Account? signIn(String email, String password) {
    final entry = _accounts[email];
    if (entry == null || entry.password != _digest(entry.salt, password)) {
      return null;
    }
    return entry.account;
  }

  Digest _digest(String salt, String password) =>
      sha256.convert(utf8.encode('$salt:$password'));

  @override
  List<HealthRecord> healthRecords(String accountId) =>
      List.unmodifiable(_records[accountId]?.values ?? const <HealthRecord>[]);

  @override
  void saveHealthRecord(String accountId, HealthRecord record) {
    final records = _records.putIfAbsent(accountId, () => {});
    final previous = records[record.id];
    if (previous != null &&
        (previous.reminder?.minuteOfDay != record.reminder?.minuteOfDay ||
            previous.reminder?.action != record.reminder?.action)) {
      _clearCompletion(accountId, record.id);
    }
    records[record.id] = record;
  }

  @override
  void deleteHealthRecord(String accountId, String recordId) {
    _records[accountId]?.remove(recordId);
    _clearCompletion(accountId, recordId);
  }

  void _clearCompletion(String accountId, String recordId) {
    for (final day in _completion[accountId]?.values ?? const <Set<String>>[]) {
      day.remove(recordId);
    }
  }

  @override
  Set<String> completedTasks(String accountId, DateTime day) =>
      Set.unmodifiable(
        _completion[accountId]?[_dateOnly(day)] ?? const <String>{},
      );

  @override
  void setCompleted(
    String accountId,
    String recordId,
    DateTime day,
    bool done,
  ) {
    final history = _completion.putIfAbsent(accountId, () => {});
    final entries = history.putIfAbsent(_dateOnly(day), () => {});
    if (done) {
      entries.add(recordId);
    } else {
      entries.remove(recordId);
    }
  }

  DateTime _dateOnly(DateTime day) => DateTime(day.year, day.month, day.day);

  @override
  List<Appointment> appointments(String accountId) =>
      List.unmodifiable(_visits[accountId] ?? const <Appointment>[]);

  @override
  bool book(String accountId, Appointment appointment) {
    final visits = _visits.putIfAbsent(accountId, () => []);
    if (visits.any(
      (visit) =>
          visit.doctor.id == appointment.doctor.id &&
          visit.time == appointment.time,
    )) {
      return false;
    }
    visits.add(appointment);
    return true;
  }

  @override
  void cancel(String accountId, Appointment appointment) =>
      _visits[accountId]?.remove(appointment);

  @override
  Map<String, List<ChatMessage>> conversations(String accountId) => {
    for (final entry
        in (_chat[accountId] ?? const <String, List<ChatMessage>>{}).entries)
      entry.key: List.unmodifiable(entry.value),
  };

  @override
  void startConversation(String accountId, String doctorId, DateTime now) {
    final threads = _chat.putIfAbsent(accountId, () => {});
    threads.putIfAbsent(
      doctorId,
      () => [ChatMessage('chat_welcome', sentAt: now)],
    );
  }

  @override
  void sendMessage(
    String accountId,
    String doctorId,
    String text,
    DateTime now,
  ) {
    startConversation(accountId, doctorId, now);
    _chat[accountId]![doctorId]!.addAll([
      ChatMessage(text, fromPatient: true, sentAt: now),
      ChatMessage('chat_reply', sentAt: now),
    ]);
  }
}
