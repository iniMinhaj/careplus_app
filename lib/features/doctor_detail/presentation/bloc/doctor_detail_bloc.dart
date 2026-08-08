import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/get_doctor_detail_usecase.dart';
import 'doctor_detail_event.dart';
import 'doctor_detail_state.dart';

class DoctorDetailBloc extends Bloc<DoctorDetailEvent, DoctorDetailState> {
  final GetDoctorDetailUsecase _getDoctorDetailUsecase;

  DoctorDetailBloc({required GetDoctorDetailUsecase getDoctorDetailUsecase})
      : _getDoctorDetailUsecase = getDoctorDetailUsecase,
        super(const DoctorDetailState()) {
    on<DoctorDetailRequested>(_onRequested);
    on<DoctorDateSelected>(_onDateSelected);
    on<DoctorSlotSelected>(_onSlotSelected);
  }

  Future<void> _onRequested(
    DoctorDetailRequested event,
    Emitter<DoctorDetailState> emit,
  ) async {
    emit(state.copyWith(
      status: DoctorDetailStatus.loading,
      clearError: true,
    ));
    final result =
        await _getDoctorDetailUsecase(GetDoctorDetailParams(doctorId: event.doctorId));
    result.fold(
      (failure) => emit(state.copyWith(
        status: DoctorDetailStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (doctorDetail) => emit(state.copyWith(
        status: DoctorDetailStatus.success,
        doctorDetail: doctorDetail,
        selectedDate: doctorDetail.availableSlots.isNotEmpty
            ? doctorDetail.availableSlots.first.date
            : null,
        clearSelectedSlot: true,
      )),
    );
  }

  void _onDateSelected(
    DoctorDateSelected event,
    Emitter<DoctorDetailState> emit,
  ) {
    emit(state.copyWith(
      selectedDate: event.date,
      clearSelectedSlot: true,
    ));
  }

  void _onSlotSelected(
    DoctorSlotSelected event,
    Emitter<DoctorDetailState> emit,
  ) {
    emit(state.copyWith(selectedSlot: event.slot));
  }
}
