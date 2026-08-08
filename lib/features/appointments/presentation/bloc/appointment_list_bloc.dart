import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecase/cancel_appointment_usecase.dart';
import '../../domain/usecase/get_appointments_usecase.dart';
import 'appointment_list_event.dart';
import 'appointment_list_state.dart';

class AppointmentListBloc
    extends Bloc<AppointmentListEvent, AppointmentListState> {
  final GetAppointmentsUsecase _getAppointmentsUsecase;
  final CancelAppointmentUsecase _cancelAppointmentUsecase;

  AppointmentListBloc({
    required GetAppointmentsUsecase getAppointmentsUsecase,
    required CancelAppointmentUsecase cancelAppointmentUsecase,
  })  : _getAppointmentsUsecase = getAppointmentsUsecase,
        _cancelAppointmentUsecase = cancelAppointmentUsecase,
        super(const AppointmentListState.initial()) {
    on<AppointmentListRequested>(_onListRequested);
    on<AppointmentCancelRequested>(_onCancelRequested);
  }

  Future<void> _onListRequested(
    AppointmentListRequested event,
    Emitter<AppointmentListState> emit,
  ) async {
    emit(state.copyWith(
      status: AppointmentListStatus.loading,
      clearError: true,
    ));
    final result = await _getAppointmentsUsecase(const NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
        status: AppointmentListStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (appointments) => emit(state.copyWith(
        status: AppointmentListStatus.success,
        appointments: appointments,
        clearError: true,
      )),
    );
  }

  Future<void> _onCancelRequested(
    AppointmentCancelRequested event,
    Emitter<AppointmentListState> emit,
  ) async {
    final result = await _cancelAppointmentUsecase(
      CancelAppointmentParams(appointmentId: event.appointmentId),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AppointmentListStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (_) {
        // Reload after mutate, same as the legacy screen — simpler than
        // patching the cancelled row into state locally.
        emit(state.copyWith(cancelledTick: state.cancelledTick + 1));
        add(const AppointmentListRequested());
      },
    );
  }
}
