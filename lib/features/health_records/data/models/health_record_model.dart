import '../../domain/entity/health_record.dart';

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
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        type: json['type'] as String? ?? 'other',
        relatedDoctorName: json['relatedDoctorName'] as String?,
        fileUrl: json['fileUrl'] as String? ?? '',
        fileType: json['fileType'] as String? ?? 'pdf',
        date: json['date'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'type': type,
        'relatedDoctorName': relatedDoctorName,
        'fileUrl': fileUrl,
        'fileType': fileType,
        'date': date,
        'notes': notes,
      };

  HealthRecord toEntity() => HealthRecord(
        id: id,
        title: title,
        type: type,
        relatedDoctorName: relatedDoctorName,
        fileUrl: fileUrl,
        fileType: fileType,
        date: date,
        notes: notes,
      );
}
