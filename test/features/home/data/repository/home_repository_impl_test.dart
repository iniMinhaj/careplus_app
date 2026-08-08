import 'package:careplus/core/error/failures.dart';
import 'package:careplus/features/home/data/datasources/remote/home_remote_datasource.dart';
import 'package:careplus/features/home/data/models/doctor_model.dart';
import 'package:careplus/features/home/data/models/specialization_model.dart';
import 'package:careplus/features/home/data/repository/home_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRemoteDataSource extends Mock implements HomeRemoteDataSource {}

void main() {
  late MockHomeRemoteDataSource mockDataSource;
  late HomeRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockHomeRemoteDataSource();
    repository = HomeRepositoryImpl(homeRemoteDataSource: mockDataSource);
  });

  group('getSpecializations', () {
    test('maps data-source models to entities on success', () async {
      when(() => mockDataSource.getSpecializations()).thenAnswer(
        (_) async => [
          SpecializationModel(
              id: 'spec_01', name: 'Cardiologist', icon: 'heart_pulse', doctorCount: 4),
        ],
      );

      final result = await repository.getSpecializations();

      expect(result.isRight(), true);
      result.match(
        (_) => fail('expected Right'),
        (specializations) {
          expect(specializations.length, 1);
          expect(specializations.first.id, 'spec_01');
        },
      );
    });

    test('maps a thrown exception to a Failure', () async {
      when(() => mockDataSource.getSpecializations())
          .thenThrow(Exception('boom'));

      final result = await repository.getSpecializations();

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('getDoctors', () {
    test('maps data-source models to entities on success', () async {
      when(() => mockDataSource.getDoctors(
            query: any(named: 'query'),
            specializationId: any(named: 'specializationId'),
            minRating: any(named: 'minRating'),
            availableOnly: any(named: 'availableOnly'),
            maxFee: any(named: 'maxFee'),
          )).thenAnswer((_) async => [
            DoctorModel(
              id: 'doc_01',
              name: 'Dr. Anika Rahman',
              specializationId: 'spec_01',
              specializationName: 'Cardiologist',
              photoUrl: '',
              experienceYears: 8,
              rating: 4.8,
              reviewCount: 120,
              consultationFee: 1000,
              currency: 'BDT',
              hospital: 'Square Hospital',
              location: 'Dhaka',
              isAvailableToday: true,
            ),
          ]);

      final result = await repository.getDoctors();

      expect(result.isRight(), true);
      result.match(
        (_) => fail('expected Right'),
        (doctors) {
          expect(doctors.length, 1);
          expect(doctors.first.id, 'doc_01');
        },
      );
    });

    test('maps a thrown exception to a Failure', () async {
      when(() => mockDataSource.getDoctors(
            query: any(named: 'query'),
            specializationId: any(named: 'specializationId'),
            minRating: any(named: 'minRating'),
            availableOnly: any(named: 'availableOnly'),
            maxFee: any(named: 'maxFee'),
          )).thenThrow(Exception('boom'));

      final result = await repository.getDoctors();

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
