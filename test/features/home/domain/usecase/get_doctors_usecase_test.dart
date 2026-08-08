import 'package:careplus/core/error/failures.dart';
import 'package:careplus/features/home/domain/entity/doctor.dart';
import 'package:careplus/features/home/domain/repository/home_repository.dart';
import 'package:careplus/features/home/domain/usecase/get_doctors_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepository;
  late GetDoctorsUsecase usecase;

  const tDoctors = [
    Doctor(
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
  ];

  setUp(() {
    mockRepository = MockHomeRepository();
    usecase = GetDoctorsUsecase(repository: mockRepository);
  });

  test('unpacks GetDoctorsParams into named args on the repository call',
      () async {
    when(() => mockRepository.getDoctors(
          query: 'Anika',
          specializationId: 'spec_01',
          minRating: 4.0,
          availableOnly: true,
          maxFee: 1200,
        )).thenAnswer((_) async => const Right(tDoctors));

    final result = await usecase(const GetDoctorsParams(
      query: 'Anika',
      specializationId: 'spec_01',
      minRating: 4.0,
      availableOnly: true,
      maxFee: 1200,
    ));

    expect(result, const Right(tDoctors));
    verify(() => mockRepository.getDoctors(
          query: 'Anika',
          specializationId: 'spec_01',
          minRating: 4.0,
          availableOnly: true,
          maxFee: 1200,
        )).called(1);
  });

  test('forwards the Failure when the repository fails', () async {
    const tFailure = UnknownFailure();
    when(() => mockRepository.getDoctors(
          query: any(named: 'query'),
          specializationId: any(named: 'specializationId'),
          minRating: any(named: 'minRating'),
          availableOnly: any(named: 'availableOnly'),
          maxFee: any(named: 'maxFee'),
        )).thenAnswer((_) async => const Left(tFailure));

    final result = await usecase(const GetDoctorsParams());

    expect(result, const Left(tFailure));
  });
}
