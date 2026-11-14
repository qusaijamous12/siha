import 'package:get/get.dart';

import '../../auth/controller/auth_controller.dart';
import '../model/doctor.dart';

class DoctorsController extends GetxController {
  DoctorsController(this._gateway, this._auth, this._now);

  final DoctorsGateway _gateway;
  final AuthController _auth;
  final DateTime Function() _now;

  final visits = <Appointment>[].obs;
  final filter = Rxn<Specialty>();
  final query = ''.obs;
  late final Worker _session;

  List<Doctor> get doctors => _gateway.doctors;

  List<Doctor> get filteredDoctors {
    final term = query.value.trim().toLowerCase();
    final specialty = filter.value;
    return doctors.where((doctor) {
      final matches = [
        doctor.id.tr,
        doctor.specialty.name.tr,
        doctor.clinicKey.tr,
      ].any((value) => value.toLowerCase().contains(term));
      return matches && (specialty == null || doctor.specialty == specialty);
    }).toList();
  }

  List<Appointment> get upcoming =>
      visits.where((visit) => visit.time.isAfter(_now())).toList();

  List<DateTime> get bookingDays {
    final now = _now();
    return List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day + index + 1),
    );
  }

  List<DateTime> availableTimes(Doctor doctor, DateTime date) {
    final now = _now();
    return doctor.slotMinutes
        .map(
          (minutes) => DateTime(
            date.year,
            date.month,
            date.day,
            minutes ~/ 60,
            minutes % 60,
          ),
        )
        .where(
          (time) =>
              time.isAfter(now) &&
              !visits.any(
                (visit) => visit.doctor.id == doctor.id && visit.time == time,
              ),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    _session = ever(_auth.account, (_) {
      filter.value = null;
      query.value = '';
      _load();
    });
  }

  void _load() {
    final account = _auth.account.value;
    final entries = account == null
        ? <Appointment>[]
        : _gateway.appointments(account.id).toList();
    entries.sort((a, b) => a.time.compareTo(b.time));
    visits.assignAll(entries);
  }

  bool book(Doctor doctor, DateTime time) {
    final account = _auth.account.value;
    if (account == null || !availableTimes(doctor, time).contains(time)) {
      return false;
    }
    final booked = _gateway.book(
      account.id,
      Appointment(doctor: doctor, time: time),
    );
    _load();
    return booked;
  }

  void cancel(Appointment appointment) {
    final account = _auth.account.value;
    if (account == null) return;
    _gateway.cancel(account.id, appointment);
    _load();
  }

  @override
  void onClose() {
    _session.dispose();
    super.onClose();
  }
}
