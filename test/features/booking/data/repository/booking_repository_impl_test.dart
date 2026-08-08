import 'package:careplus/core/error/failures.dart';
import 'package:careplus/features/booking/data/datasources/remote/booking_remote_datasource.dart';
import 'package:careplus/features/booking/data/models/appointment_model.dart';
import 'package:careplus/features/booking/data/repository/booking_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBookingRemoteDataSource extends Mock
    implements BookingRemoteDataSource {}

void main() {
  late MockBookingRemoteDataSource mockDataSource;
  late BookingRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockBookingRemoteDataSource();
    repository = BookingRepositoryImpl(bookingRemoteDataSource: mockDataSource);
  });

  group('bookAppointment', () {
    test('maps the data-source model to an entity on success', () async {
      when(() => mockDataSource.bookAppointment(
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
          )).thenAnswer((_) async => AppointmentModel(
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
          ));

      final result = await repository.bookAppointment(
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
      );

      expect(result.isRight(), true);
      result.match(
        (_) => fail('expected Right'),
        (appointment) {
          expect(appointment.id, 'appt_001');
          expect(appointment.doctorName, 'Dr. Anika Rahman');
        },
      );
    });

    test('maps a thrown exception to a Failure', () async {
      when(() => mockDataSource.bookAppointment(
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
          )).thenThrow(Exception('boom'));

      final result = await repository.bookAppointment(
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
      );

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
