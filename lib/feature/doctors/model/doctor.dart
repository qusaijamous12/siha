enum Specialty { family, cardiology, dermatology }

class Doctor {
  const Doctor({
    required this.id,
    required this.specialty,
    required this.initials,
    required this.arabicInitials,
    required this.slotMinutes,
  });

  final String id;
  final Specialty specialty;
  final String initials;
  final String arabicInitials;
  final List<int> slotMinutes;

  String get clinicKey => '${id}_clinic';
  String get bioKey => '${id}_bio';
}

class Appointment {
  const Appointment({required this.doctor, required this.time});

  final Doctor doctor;
  final DateTime time;
}

abstract interface class DoctorsGateway {
  List<Doctor> get doctors;
  List<Appointment> appointments(String accountId);
  bool book(String accountId, Appointment appointment);
  void cancel(String accountId, Appointment appointment);
}
