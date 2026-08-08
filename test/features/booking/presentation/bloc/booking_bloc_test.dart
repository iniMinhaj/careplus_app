import 'package:bloc_test/bloc_test.dart';
import 'package:careplus/core/error/failures.dart';
import 'package:careplus/features/booking/domain/entity/appointment.dart';
import 'package:careplus/features/booking/domain/usecase/book_appointment_usecase.dart';
import 'package:careplus/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:careplus/features/booking/presentation/bloc/booking_event.dart';
import 'package:careplus/features/booking/presentation/bloc/booking_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockBookAppointmentUsecase extends Mock
    implements BookAppointmentUsecase {}

void main() {
  late MockBookAppointmentUsecase mockBookAppointmentUsecase;

  const tStarted = BookingStarted(
    doctorId: 'doc_01',
    doctorName: 'Dr. Anika Rahman',
    doctorPhotoUrl: '',
    specializationName: 'Cardiologist',
    consultationFee: 1000,
    currency: 'BDT',
    date: '2026-08-10',
    time: '10:00 AM',
  );

  const tSeededState = BookingState(
    doctorId: 'doc_01',
    doctorName: 'Dr. Anika Rahman',
    doctorPhotoUrl: '',
    specializationName: 'Cardiologist',
    consultationFee: 1000,
    currency: 'BDT',
    date: '2026-08-10',
    time: '10:00 AM',
  );

  const tAppointment = Appointment(
    id: 'appt_001',
    doctorId: 'doc_01',
    doctorName: 'Dr. Anika Rahman',
    doctorPhotoUrl: '',
    specializationName: 'Cardiologist',
    date: '2026-08-10',
    time: '10:00 AM',
    status: 'upcoming',
    fee: 1000,
    currency: 'BDT',
    paymentStatus: 'paid',
    paymentMethod: 'bkash',
    consultationType: 'video',
    reasonForVisit: 'General consultation',
  );

  const tFailure = UnknownFailure();

  setUpAll(() {
    registerFallbackValue(const BookAppointmentParams(
      doctorId: '',
      doctorName: '',
      doctorPhotoUrl: '',
      specializationName: '',
      date: '',
      time: '',
      fee: 0,
      currency: '',
      consultationType: '',
      reasonForVisit: '',
      paymentMethod: '',
    ));
  });

  setUp(() {
    mockBookAppointmentUsecase = MockBookAppointmentUsecase();
  });

  blocTest<BookingBloc, BookingState>(
    'seeds doctor and slot details when BookingStarted is added',
    build: () =>
        BookingBloc(bookAppointmentUsecase: mockBookAppointmentUsecase),
    act: (bloc) => bloc.add(tStarted),
    expect: () => [tSeededState],
  );

  blocTest<BookingBloc, BookingState>(
    'emits [submitting, success] when PaymentSubmitted succeeds',
    seed: () => tSeededState,
    setUp: () {
      when(() => mockBookAppointmentUsecase(any()))
          .thenAnswer((_) async => const Right(tAppointment));
    },
    build: () =>
        BookingBloc(bookAppointmentUsecase: mockBookAppointmentUsecase),
    act: (bloc) => bloc.add(const PaymentSubmitted()),
    expect: () => [
      tSeededState.copyWith(status: BookingStatus.submitting),
      tSeededState.copyWith(
        status: BookingStatus.success,
        appointment: tAppointment,
      ),
    ],
  );

  blocTest<BookingBloc, BookingState>(
    'emits [submitting, failure] when PaymentSubmitted fails',
    seed: () => tSeededState,
    setUp: () {
      when(() => mockBookAppointmentUsecase(any()))
          .thenAnswer((_) async => const Left(tFailure));
    },
    build: () =>
        BookingBloc(bookAppointmentUsecase: mockBookAppointmentUsecase),
    act: (bloc) => bloc.add(const PaymentSubmitted()),
    expect: () => [
      tSeededState.copyWith(status: BookingStatus.submitting),
      tSeededState.copyWith(
        status: BookingStatus.failure,
        errorMessage: tFailure.userMessage,
      ),
    ],
  );

  blocTest<BookingBloc, BookingState>(
    'defaults an empty reason to "General consultation" on submit',
    seed: () => tSeededState,
    setUp: () {
      when(() => mockBookAppointmentUsecase(any()))
          .thenAnswer((_) async => const Right(tAppointment));
    },
    build: () =>
        BookingBloc(bookAppointmentUsecase: mockBookAppointmentUsecase),
    act: (bloc) => bloc.add(const PaymentSubmitted()),
    verify: (_) {
      verify(() => mockBookAppointmentUsecase(const BookAppointmentParams(
            doctorId: 'doc_01',
            doctorName: 'Dr. Anika Rahman',
            doctorPhotoUrl: '',
            specializationName: 'Cardiologist',
            date: '2026-08-10',
            time: '10:00 AM',
            fee: 1000,
            currency: 'BDT',
            consultationType: 'video',
            reasonForVisit: 'General consultation',
            paymentMethod: 'bkash',
          ))).called(1);
    },
  );
}
