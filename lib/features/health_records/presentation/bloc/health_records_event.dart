import 'package:equatable/equatable.dart';

sealed class HealthRecordsEvent extends Equatable {
  const HealthRecordsEvent();

  @override
  List<Object?> get props => [];
}

class HealthRecordsRequested extends HealthRecordsEvent {
  const HealthRecordsRequested();
}

class HealthRecordUploadRequested extends HealthRecordsEvent {
  final String title;
  final String type;
  final String filePath;
  final String fileType;
  final String? notes;

  const HealthRecordUploadRequested({
    required this.title,
    required this.type,
    required this.filePath,
    required this.fileType,
    this.notes,
  });

  @override
  List<Object?> get props => [title, type, filePath, fileType, notes];
}
