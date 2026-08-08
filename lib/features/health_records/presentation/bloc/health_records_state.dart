import 'package:equatable/equatable.dart';

import '../../domain/entity/health_record.dart';

enum HealthRecordsStatus { initial, loading, success, failure }

/// Kept separate from [HealthRecordsStatus] so an in-flight upload can show
/// a lightweight overlay/snackbar on top of the still-visible list, rather
/// than replacing the whole screen with a spinner.
enum HealthRecordUploadStatus { idle, uploading, success, failure }

class HealthRecordsState extends Equatable {
  final HealthRecordsStatus status;
  final List<HealthRecord> records;
  final String? errorMessage;
  final HealthRecordUploadStatus uploadStatus;
  final String? uploadErrorMessage;

  const HealthRecordsState({
    this.status = HealthRecordsStatus.initial,
    this.records = const [],
    this.errorMessage,
    this.uploadStatus = HealthRecordUploadStatus.idle,
    this.uploadErrorMessage,
  });

  const HealthRecordsState.initial() : this();

  HealthRecordsState copyWith({
    HealthRecordsStatus? status,
    List<HealthRecord>? records,
    String? errorMessage,
    bool clearError = false,
    HealthRecordUploadStatus? uploadStatus,
    String? uploadErrorMessage,
    bool clearUploadError = false,
  }) {
    return HealthRecordsState(
      status: status ?? this.status,
      records: records ?? this.records,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadErrorMessage: clearUploadError
          ? null
          : (uploadErrorMessage ?? this.uploadErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        records,
        errorMessage,
        uploadStatus,
        uploadErrorMessage,
      ];
}
