// All plain data models for CarePlus.
// Kept intentionally simple (fromJson only) so that later, when you introduce
// BLoC/Riverpod + a real API, these become your `domain/entities` +
// `data/models` pair with minimal rewrite.

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String photoUrl;
  final String bloodGroup;
  final String address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.photoUrl,
    required this.bloodGroup,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        photoUrl: json['photoUrl'] ?? '',
        bloodGroup: json['bloodGroup'] ?? '',
        address: json['address'] ?? '',
      );
}

class SpecializationModel {
  final String id;
  final String name;
  final String icon;
  final int doctorCount;

  SpecializationModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.doctorCount,
  });

  factory SpecializationModel.fromJson(Map<String, dynamic> json) =>
      SpecializationModel(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        doctorCount: json['doctorCount'] ?? 0,
      );
}

class SlotGroup {
  final String date;
  final List<String> slots;

  SlotGroup({required this.date, required this.slots});

  factory SlotGroup.fromJson(Map<String, dynamic> json) => SlotGroup(
        date: json['date'],
        slots: List<String>.from(json['slots'] ?? []),
      );
}

class DoctorModel {
  final String id;
  final String name;
  final String specializationId;
  final String specializationName;
  final String photoUrl;
  final int experienceYears;
  final double rating;
  final int reviewCount;
  final int consultationFee;
  final String currency;
  final String hospital;
  final String location;
  final String bio;
  final List<String> education;
  final List<String> languages;
  final bool isAvailableToday;
  final List<SlotGroup> availableSlots;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specializationId,
    required this.specializationName,
    required this.photoUrl,
    required this.experienceYears,
    required this.rating,
    required this.reviewCount,
    required this.consultationFee,
    required this.currency,
    required this.hospital,
    required this.location,
    required this.bio,
    required this.education,
    required this.languages,
    required this.isAvailableToday,
    required this.availableSlots,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) => DoctorModel(
        id: json['id'],
        name: json['name'],
        specializationId: json['specializationId'],
        specializationName: json['specializationName'],
        photoUrl: json['photoUrl'],
        experienceYears: json['experienceYears'] ?? 0,
        rating: (json['rating'] ?? 0).toDouble(),
        reviewCount: json['reviewCount'] ?? 0,
        consultationFee: json['consultationFee'] ?? 0,
        currency: json['currency'] ?? 'BDT',
        hospital: json['hospital'] ?? '',
        location: json['location'] ?? '',
        bio: json['bio'] ?? '',
        education: List<String>.from(json['education'] ?? []),
        languages: List<String>.from(json['languages'] ?? []),
        isAvailableToday: json['isAvailableToday'] ?? false,
        availableSlots: (json['availableSlots'] as List? ?? [])
            .map((e) => SlotGroup.fromJson(e))
            .toList(),
      );
}

class AppointmentModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorPhotoUrl;
  final String specializationName;
  final String date;
  final String time;
  final String status; // upcoming, ongoing, completed, cancelled
  final int fee;
  final String currency;
  final String paymentStatus;
  final String paymentMethod;
  final String consultationType;
  final String reasonForVisit;

  AppointmentModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorPhotoUrl,
    required this.specializationName,
    required this.date,
    required this.time,
    required this.status,
    required this.fee,
    required this.currency,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.consultationType,
    required this.reasonForVisit,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      AppointmentModel(
        id: json['id'],
        patientId: json['patientId'] ?? '',
        doctorId: json['doctorId'] ?? '',
        doctorName: json['doctorName'] ?? '',
        doctorPhotoUrl: json['doctorPhotoUrl'] ?? '',
        specializationName: json['specializationName'] ?? '',
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        status: json['status'] ?? 'upcoming',
        fee: json['fee'] ?? 0,
        currency: json['currency'] ?? 'BDT',
        paymentStatus: json['paymentStatus'] ?? '',
        paymentMethod: json['paymentMethod'] ?? '',
        consultationType: json['consultationType'] ?? 'in-person',
        reasonForVisit: json['reasonForVisit'] ?? '',
      );
}

class HealthRecordModel {
  final String id;
  final String title;
  final String type;
  final String? relatedDoctorName;
  final String fileUrl;
  final String fileType;
  final String date;
  final String notes;

  HealthRecordModel({
    required this.id,
    required this.title,
    required this.type,
    required this.relatedDoctorName,
    required this.fileUrl,
    required this.fileType,
    required this.date,
    required this.notes,
  });

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) =>
      HealthRecordModel(
        id: json['id'],
        title: json['title'] ?? '',
        type: json['type'] ?? 'other',
        relatedDoctorName: json['relatedDoctorName'],
        fileUrl: json['fileUrl'] ?? '',
        fileType: json['fileType'] ?? 'pdf',
        date: json['date'] ?? '',
        notes: json['notes'] ?? '',
      );
}

class AdherenceLog {
  final String date;
  final String time;
  final bool taken;

  AdherenceLog({required this.date, required this.time, required this.taken});

  factory AdherenceLog.fromJson(Map<String, dynamic> json) => AdherenceLog(
        date: json['date'],
        time: json['time'],
        taken: json['taken'] ?? false,
      );
}

class MedicineModel {
  final String id;
  final String name;
  final String dosage;
  final String form;
  final String frequency;
  final List<String> reminderTimes;
  final String startDate;
  final String endDate;
  final String instructions;
  final bool isActive;
  final List<AdherenceLog> adherenceLog;

  MedicineModel({
    required this.id,
    required this.name,
    required this.dosage,
    required this.form,
    required this.frequency,
    required this.reminderTimes,
    required this.startDate,
    required this.endDate,
    required this.instructions,
    required this.isActive,
    required this.adherenceLog,
  });

  factory MedicineModel.fromJson(Map<String, dynamic> json) => MedicineModel(
        id: json['id'],
        name: json['name'] ?? '',
        dosage: json['dosage'] ?? '',
        form: json['form'] ?? 'tablet',
        frequency: json['frequency'] ?? 'once_daily',
        reminderTimes: List<String>.from(json['reminderTimes'] ?? []),
        startDate: json['startDate'] ?? '',
        endDate: json['endDate'] ?? '',
        instructions: json['instructions'] ?? '',
        isActive: json['isActive'] ?? true,
        adherenceLog: (json['adherenceLog'] as List? ?? [])
            .map((e) => AdherenceLog.fromJson(e))
            .toList(),
      );
}

class PaymentModel {
  final String id;
  final String appointmentId;
  final int amount;
  final String currency;
  final String method;
  final String status;
  final String transactionId;
  final String paidAt;

  PaymentModel({
    required this.id,
    required this.appointmentId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    required this.transactionId,
    required this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => PaymentModel(
        id: json['id'],
        appointmentId: json['appointmentId'] ?? '',
        amount: json['amount'] ?? 0,
        currency: json['currency'] ?? 'BDT',
        method: json['method'] ?? '',
        status: json['status'] ?? '',
        transactionId: json['transactionId'] ?? '',
        paidAt: json['paidAt'] ?? '',
      );
}
