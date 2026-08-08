import 'package:careplus/core/error/failures.dart';
import 'package:careplus/features/booking/domain/entity/appointment.dart';
import 'package:careplus/features/booking/domain/repository/booking_repository.dart';
import 'package:careplus/features/booking/domain/usecase/book_appointment_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRepository extends Mock implements BookingRepository {}

void main() {
  late MockBookingRepository mockRepository;
  late BookAppointmentUsecase usecase;

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
    reasonForVisit: 'Routine checkup',
  );

  setUp(() {
    mockRepository = MockBookingRepository();
    usecase = BookAppointmentUsecase(repository: mockRepository);
  });

  test('unpacks BookAppointmentParams into named args on the repository call',
      () async {
    when(() => mockRepository.bookAppointment(
          doctorId: 'doc_01',
          doctorName: 'Dr. Anika Rahman',
          doctorPhotoUrl: '',
          specializationName: 'Cardiologist',
          date: '2026-08-10',
          time: '10:00 AM',
          fee: 1000,
          currency: 'BDT',
          consultationType: 'video',
          reasonForVisit: 'Routine checkup',
          paymentMethod: 'bkash',
        )).thenAnswer((_) async => const Right(tAppointment));

    final result = await usecase(const BookAppointmentParams(
      doctorId: 'doc_01',
      doctorName: 'Dr. Anika Rahman',
      doctorPhotoUrl: '',
      specializationName: 'Cardiologist',
      date: '2026-08-10',
      time: '10:00 AM',
      fee: 1000,
      currency: 'BDT',
      consultationType: 'video',
      reasonForVisit: 'Routine checkup',
      paymentMethod: 'bkash',
    ));

    expect(result, const Right(tAppointment));
    verify(() => mockRepository.bookAppointment(
          doctorId: 'doc_01',
          doctorName: 'Dr. Anika Rahman',
          doctorPhotoUrl: '',
          specializationName: 'Cardiologist',
          date: '2026-08-10',
          time: '10:00 AM',
          fee: 1000,
          currency: 'BDT',
          consultationType: 'video',
          reasonForVisit: 'Routine checkup',
          paymentMethod: 'bkash',
        )).called(1);
  });

  test('forwards the Failure when the repository fails', () async {
    const tFailure = UnknownFailure();
    when(() => mockRepository.bookAppointment(
          doctorId: any(named: 'doctorId'),
          doctorName: any(named: 'doctorName'),
          doctorPhotoUrl: any(named: 'doctorPhotoUrl'),
          specializationName: any(named: 'specializationName'),
          date: any(named: 'date'),
          time: any(named: 'time'),
          fee: any(named: 'fee'),
          currency: any(named: 'currency'),
          consultationType: any(named: 'consultationType'),
          reasonForVisit: any(named: 'reasonForVisit'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenAnswer((_) async => const Left(tFailure));

    final result = await usecase(const BookAppointmentParams(
      doctorId: 'doc_01',
      doctorName: 'Dr. Anika Rahman',
      doctorPhotoUrl: '',
      specializationName: 'Cardiologist',
      date: '2026-08-10',
      time: '10:00 AM',
      fee: 1000,
      currency: 'BDT',
      consultationType: 'video',
      reasonForVisit: 'Routine checkup',
      paymentMethod: 'bkash',
    ));

    expect(result, const Left(tFailure));
  });
}
