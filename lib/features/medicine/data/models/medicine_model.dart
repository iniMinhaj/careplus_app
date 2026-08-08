import '../../domain/entity/medicine.dart';

class AdherenceEntryModel {
  final String date;
  final String time;
  final bool taken;

  AdherenceEntryModel({
    required this.date,
    required this.time,
    required this.taken,
  });

  factory AdherenceEntryModel.fromJson(Map<String, dynamic> json) =>
      AdherenceEntryModel(
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        taken: json['taken'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'date': date,
        'time': time,
        'taken': taken,
      };

  AdherenceEntry toEntity() =>
      AdherenceEntry(date: date, time: time, taken: taken);
}

class MedicineModel {
  final String id;
  final String patientId;
  final String name;
  final String dosage;
  final String form;
  final String frequency;
  final List<String> reminderTimes;
  final String startDate;
  final String endDate;
  final String instructions;
  final bool isActive;
  final List<AdherenceEntryModel> adherenceLog;

  MedicineModel({
    required this.id,
    required this.patientId,
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
        patientId: json['patientId'] ?? '',
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
            .map((e) => AdherenceEntryModel.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'name': name,
        'dosage': dosage,
        'form': form,
        'frequency': frequency,
        'reminderTimes': reminderTimes,
        'startDate': startDate,
        'endDate': endDate,
        'instructions': instructions,
        'isActive': isActive,
        'adherenceLog': adherenceLog.map((e) => e.toJson()).toList(),
      };

  Medicine toEntity() => Medicine(
        id: id,
        name: name,
        dosage: dosage,
        form: form,
        frequency: frequency,
        reminderTimes: reminderTimes,
        startDate: startDate,
        endDate: endDate,
        instructions: instructions,
        isActive: isActive,
        adherenceLog: adherenceLog.map((e) => e.toEntity()).toList(),
      );
}
