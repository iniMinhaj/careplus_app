import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/book_appointment_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookAppointmentUsecase _bookAppointmentUsecase;

  BookingBloc({required BookAppointmentUsecase bookAppointmentUsecase})
      : _bookAppointmentUsecase = bookAppointmentUsecase,
        super(const BookingState()) {
    on<BookingStarted>(_onStarted);
    on<ConsultationTypeChanged>(_onConsultationTypeChanged);
    on<ReasonForVisitChanged>(_onReasonForVisitChanged);
    on<PaymentMethodChanged>(_onPaymentMethodChanged);
    on<PaymentSubmitted>(_onPaymentSubmitted);
  }

  void _onStarted(BookingStarted event, Emitter<BookingState> emit) {
    emit(state.copyWith(
      doctorId: event.doctorId,
      doctorName: event.doctorName,
      doctorPhotoUrl: event.doctorPhotoUrl,
      specializationName: event.specializationName,
      consultationFee: event.consultationFee,
      currency: event.currency,
      date: event.date,
      time: event.time,
    ));
  }

  void _onConsultationTypeChanged(
    ConsultationTypeChanged event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(consultationType: event.consultationType));
  }

  void _onReasonForVisitChanged(
    ReasonForVisitChanged event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(reasonForVisit: event.reasonForVisit));
  }

  void _onPaymentMethodChanged(
    PaymentMethodChanged event,
    Emitter<BookingState> emit,
  ) {
    emit(state.copyWith(paymentMethod: event.paymentMethod));
  }

  Future<void> _onPaymentSubmitted(
    PaymentSubmitted event,
    Emitter<BookingState> emit,
  ) async {
    emit(state.copyWith(status: BookingStatus.submitting, clearError: true));
    final result = await _bookAppointmentUsecase(BookAppointmentParams(
      doctorId: state.doctorId,
      doctorName: state.doctorName,
      doctorPhotoUrl: state.doctorPhotoUrl,
      specializationName: state.specializationName,
      date: state.date,
      time: state.time,
      fee: state.consultationFee,
      currency: state.currency,
      consultationType: state.consultationType,
      reasonForVisit: state.reasonForVisit.trim().isEmpty
          ? 'General consultation'
          : state.reasonForVisit.trim(),
      paymentMethod: state.paymentMethod,
    ));
    result.fold(
      (failure) => emit(state.copyWith(
        status: BookingStatus.failure,
        errorMessage: failure.userMessage,
      )),
      (appointment) => emit(state.copyWith(
        status: BookingStatus.success,
        appointment: appointment,
      )),
    );
  }
}
