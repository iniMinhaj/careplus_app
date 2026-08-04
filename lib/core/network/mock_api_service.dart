import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/models.dart';

class MockApiService {
  MockApiService._internal();
  static final MockApiService instance = MockApiService._internal();

  // in-memory mutable copies so booking / marking-taken feel "real" during the demo
  List<AppointmentModel>? _appointmentsCache;
  List<MedicineModel>? _medicinesCache;

  Future<T> _simulateLatency<T>(T Function() body, {int ms = 600}) async {
    await Future.delayed(Duration(milliseconds: ms));
    return body();
  }

  Future<Map<String, dynamic>> _loadJson(String fileName) async {
    final raw = await rootBundle.loadString('assets/mock/$fileName');
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ---------------- AUTH ----------------

  Future<UserModel> login(String email, String password) async {
    final json = await _loadJson('users.json');
    return _simulateLatency(() {
      final userJson = json['auth_responses']['login_success']['user'];
      return UserModel.fromJson({
        ...userJson,
        'photoUrl': json['current_user']['photoUrl'],
        'bloodGroup': json['current_user']['bloodGroup'],
        'address': json['current_user']['address'],
      });
    });
  }

  Future<String> requestOtp(String phone) async {
    return _simulateLatency(() => 'otp_ref_88231', ms: 500);
  }

  Future<bool> verifyOtp(String otp) async {
    return _simulateLatency(() => otp.length == 4, ms: 500);
  }

  Future<UserModel> getCurrentUser() async {
    final json = await _loadJson('users.json');
    return _simulateLatency(() => UserModel.fromJson(json['current_user']));
  }

  // ---------------- SPECIALIZATIONS ----------------

  Future<List<SpecializationModel>> getSpecializations() async {
    final json = await _loadJson('specializations.json');
    return _simulateLatency(() => (json['specializations'] as List)
        .map((e) => SpecializationModel.fromJson(e))
        .toList());
  }

  // ---------------- DOCTORS ----------------

  Future<List<DoctorModel>> getDoctors({String? specializationId}) async {
    final json = await _loadJson('doctors.json');
    return _simulateLatency(() {
      final all = (json['doctors'] as List)
          .map((e) => DoctorModel.fromJson(e))
          .toList();
      if (specializationId == null) return all;
      return all.where((d) => d.specializationId == specializationId).toList();
    });
  }

  Future<List<DoctorModel>> searchDoctors(String query) async {
    final json = await _loadJson('doctors.json');
    return _simulateLatency(() {
      final all = (json['doctors'] as List)
          .map((e) => DoctorModel.fromJson(e))
          .toList();
      if (query.trim().isEmpty) return all;
      final q = query.toLowerCase();
      return all
          .where((d) =>
              d.name.toLowerCase().contains(q) ||
              d.specializationName.toLowerCase().contains(q) ||
              d.hospital.toLowerCase().contains(q))
          .toList();
    }, ms: 400);
  }

  Future<DoctorModel> getDoctorById(String id) async {
    final json = await _loadJson('doctors.json');
    return _simulateLatency(() {
      final all = (json['doctors'] as List)
          .map((e) => DoctorModel.fromJson(e))
          .toList();
      return all.firstWhere((d) => d.id == id);
    });
  }

  // ---------------- APPOINTMENTS ----------------

  Future<List<AppointmentModel>> getAppointments() async {
    if (_appointmentsCache != null) {
      return _simulateLatency(() => _appointmentsCache!, ms: 300);
    }
    final json = await _loadJson('appointments.json');
    return _simulateLatency(() {
      _appointmentsCache = (json['appointments'] as List)
          .map((e) => AppointmentModel.fromJson(e))
          .toList();
      return _appointmentsCache!;
    });
  }

  Future<AppointmentModel> bookAppointment({
    required DoctorModel doctor,
    required String date,
    required String time,
    required String consultationType,
    required String reasonForVisit,
    required String paymentMethod,
  }) async {
    await getAppointments(); // ensure cache warm
    return _simulateLatency(() {
      final newAppt = AppointmentModel(
        id: 'appt_${DateTime.now().millisecondsSinceEpoch}',
        patientId: 'usr_001',
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorPhotoUrl: doctor.photoUrl,
        specializationName: doctor.specializationName,
        date: date,
        time: time,
        status: 'upcoming',
        fee: doctor.consultationFee,
        currency: doctor.currency,
        paymentStatus: 'paid',
        paymentMethod: paymentMethod,
        consultationType: consultationType,
        reasonForVisit: reasonForVisit,
      );
      _appointmentsCache = [newAppt, ..._appointmentsCache!];
      return newAppt;
    }, ms: 900);
  }

  Future<void> cancelAppointment(String id) async {
    await getAppointments();
    return _simulateLatency(() {
      _appointmentsCache = _appointmentsCache!.map((a) {
        if (a.id == id) {
          return AppointmentModel(
            id: a.id,
            patientId: a.patientId,
            doctorId: a.doctorId,
            doctorName: a.doctorName,
            doctorPhotoUrl: a.doctorPhotoUrl,
            specializationName: a.specializationName,
            date: a.date,
            time: a.time,
            status: 'cancelled',
            fee: a.fee,
            currency: a.currency,
            paymentStatus: 'refunded',
            paymentMethod: a.paymentMethod,
            consultationType: a.consultationType,
            reasonForVisit: a.reasonForVisit,
          );
        }
        return a;
      }).toList();
    });
  }

  // ---------------- HEALTH RECORDS ----------------

  Future<List<HealthRecordModel>> getHealthRecords() async {
    final json = await _loadJson('health_records.json');
    return _simulateLatency(() => (json['health_records'] as List)
        .map((e) => HealthRecordModel.fromJson(e))
        .toList());
  }

  // ---------------- MEDICINES ----------------

  Future<List<MedicineModel>> getMedicines() async {
    if (_medicinesCache != null) {
      return _simulateLatency(() => _medicinesCache!, ms: 300);
    }
    final json = await _loadJson('medicines.json');
    return _simulateLatency(() {
      _medicinesCache = (json['medicines'] as List)
          .map((e) => MedicineModel.fromJson(e))
          .toList();
      return _medicinesCache!;
    });
  }

  Future<MedicineModel> addMedicine({
    required String name,
    required String dosage,
    required String frequency,
    required List<String> reminderTimes,
    required String instructions,
  }) async {
    await getMedicines();
    return _simulateLatency(() {
      final newMed = MedicineModel(
        id: 'med_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        dosage: dosage,
        form: 'tablet',
        frequency: frequency,
        reminderTimes: reminderTimes,
        startDate: DateTime.now().toIso8601String().split('T').first,
        endDate: DateTime.now()
            .add(const Duration(days: 7))
            .toIso8601String()
            .split('T')
            .first,
        instructions: instructions,
        isActive: true,
        adherenceLog: [],
      );
      _medicinesCache = [newMed, ..._medicinesCache!];
      return newMed;
    }, ms: 700);
  }

  Future<void> markMedicineTaken(String medicineId, String time) async {
    await getMedicines();
    return _simulateLatency(() {
      _medicinesCache = _medicinesCache!.map((m) {
        if (m.id == medicineId) {
          final today = DateTime.now().toIso8601String().split('T').first;
          final updatedLog = [
            ...m.adherenceLog,
            AdherenceLog(date: today, time: time, taken: true),
          ];
          return MedicineModel(
            id: m.id,
            name: m.name,
            dosage: m.dosage,
            form: m.form,
            frequency: m.frequency,
            reminderTimes: m.reminderTimes,
            startDate: m.startDate,
            endDate: m.endDate,
            instructions: m.instructions,
            isActive: m.isActive,
            adherenceLog: updatedLog,
          );
        }
        return m;
      }).toList();
    }, ms: 300);
  }

  // ---------------- PAYMENTS ----------------

  Future<List<PaymentModel>> getPayments() async {
    final json = await _loadJson('payments.json');
    return _simulateLatency(() => (json['payments'] as List)
        .map((e) => PaymentModel.fromJson(e))
        .toList());
  }
}
