import 'package:equatable/equatable.dart';

class HealthRecord extends Equatable {
  final String id;
  final String title;
  final String type;
  final String? relatedDoctorName;
  final String fileUrl;
  final String fileType;
  final String date;
  final String notes;

  const HealthRecord({
    required this.id,
    required this.title,
    required this.type,
    required this.relatedDoctorName,
    required this.fileUrl,
    required this.fileType,
    required this.date,
    required this.notes,
  });

  /// Seed rows point at fake `https://example.com/mock-files/...` URLs and
  /// should keep showing the icon-placeholder treatment. Records created via
  /// the real upload flow store an on-device path instead, so they can be
  /// rendered with `Image.file`/local rendering.
  bool get isLocalFile => !fileUrl.startsWith('http');

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        relatedDoctorName,
        fileUrl,
        fileType,
        date,
        notes,
      ];
}
