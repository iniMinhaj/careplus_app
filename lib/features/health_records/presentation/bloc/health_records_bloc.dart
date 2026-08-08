import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/get_health_records_usecase.dart';
import '../../domain/usecase/upload_health_record_usecase.dart';
import '../../../../core/usecase/usecase.dart';
import 'health_records_event.dart';
import 'health_records_state.dart';

class HealthRecordsBloc extends Bloc<HealthRecordsEvent, HealthRecordsState> {
  final GetHealthRecordsUsecase _getHealthRecordsUsecase;
  final UploadHealthRecordUsecase _uploadHealthRecordUsecase;

  HealthRecordsBloc({
    required GetHealthRecordsUsecase getHealthRecordsUsecase,
    required UploadHealthRecordUsecase uploadHealthRecordUsecase,
  })  : _getHealthRecordsUsecase = getHealthRecordsUsecase,
        _uploadHealthRecordUsecase = uploadHealthRecordUsecase,
        super(const HealthRecordsState.initial()) {
    on<HealthRecordsRequested>(_onRecordsRequested);
    on<HealthRecordUploadRequested>(_onUploadRequested);
  }

  Future<void> _onRecordsRequested(
    HealthRecordsRequested event,
    Emitter<HealthRecordsState> emit,
  ) async {
    emit(state.copyWith(
      status: HealthRecordsStatus.loading,
      clearError: true,
    ));
    final result = await _getHealthRecordsUsecase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: HealthRecordsStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (records) => emit(state.copyWith(
        status: HealthRecordsStatus.success,
        records: records,
        clearError: true,
      )),
    );
  }

  Future<void> _onUploadRequested(
    HealthRecordUploadRequested event,
    Emitter<HealthRecordsState> emit,
  ) async {
    emit(state.copyWith(
      uploadStatus: HealthRecordUploadStatus.uploading,
      clearUploadError: true,
    ));
    final result = await _uploadHealthRecordUsecase(UploadHealthRecordParams(
      title: event.title,
      type: event.type,
      filePath: event.filePath,
      fileType: event.fileType,
      notes: event.notes,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        uploadStatus: HealthRecordUploadStatus.failure,
        uploadErrorMessage: failure.userMessage,
      )),
      (record) {
        emit(state.copyWith(
          uploadStatus: HealthRecordUploadStatus.success,
          clearUploadError: true,
        ));
        add(const HealthRecordsRequested());
      },
    );
  }
}
