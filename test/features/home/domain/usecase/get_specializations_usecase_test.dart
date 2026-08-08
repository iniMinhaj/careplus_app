import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/home/domain/entity/specialization.dart';
import 'package:careplus/features/home/domain/repository/home_repository.dart';
import 'package:careplus/features/home/domain/usecase/get_specializations_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository mockRepository;
  late GetSpecializationsUsecase usecase;

  const tSpecializations = [
    Specialization(id: 'spec_01', name: 'Cardiologist', icon: 'heart_pulse', doctorCount: 4),
  ];

  setUp(() {
    mockRepository = MockHomeRepository();
    usecase = GetSpecializationsUsecase(repository: mockRepository);
  });

  test('forwards to HomeRepository.getSpecializations on success', () async {
    when(() => mockRepository.getSpecializations())
        .thenAnswer((_) async => const Right(tSpecializations));

    final result = await usecase(const NoParams());

    expect(result, const Right(tSpecializations));
    verify(() => mockRepository.getSpecializations()).called(1);
  });

  test('forwards the Failure when the repository fails', () async {
    const tFailure = UnknownFailure();
    when(() => mockRepository.getSpecializations())
        .thenAnswer((_) async => const Left(tFailure));

    final result = await usecase(const NoParams());

    expect(result, const Left(tFailure));
  });
}
