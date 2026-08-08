import 'package:bloc_test/bloc_test.dart';
import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/home/domain/entity/specialization.dart';
import 'package:careplus/features/home/domain/usecase/get_specializations_usecase.dart';
import 'package:careplus/features/home/presentation/bloc/specialization/specialization_bloc.dart';
import 'package:careplus/features/home/presentation/bloc/specialization/specialization_event.dart';
import 'package:careplus/features/home/presentation/bloc/specialization/specialization_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetSpecializationsUsecase extends Mock
    implements GetSpecializationsUsecase {}

void main() {
  late MockGetSpecializationsUsecase mockGetSpecializationsUsecase;

  const tSpecializations = [
    Specialization(id: 'spec_01', name: 'Cardiologist', icon: 'heart_pulse', doctorCount: 4),
    Specialization(id: 'spec_02', name: 'Dermatologist', icon: 'skin', doctorCount: 3),
  ];
  const tFailure = UnknownFailure();

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetSpecializationsUsecase = MockGetSpecializationsUsecase();
  });

  blocTest<SpecializationBloc, SpecializationState>(
    'emits [loading, success] when SpecializationRequested succeeds',
    setUp: () {
      when(() => mockGetSpecializationsUsecase(any()))
          .thenAnswer((_) async => const Right(tSpecializations));
    },
    build: () => SpecializationBloc(
        getSpecializationsUsecase: mockGetSpecializationsUsecase),
    act: (bloc) => bloc.add(const SpecializationRequested()),
    expect: () => [
      const SpecializationState(status: SpecializationStatus.loading),
      const SpecializationState(
        status: SpecializationStatus.success,
        specializations: tSpecializations,
      ),
    ],
  );

  blocTest<SpecializationBloc, SpecializationState>(
    'emits [loading, failure] when SpecializationRequested fails',
    setUp: () {
      when(() => mockGetSpecializationsUsecase(any()))
          .thenAnswer((_) async => const Left(tFailure));
    },
    build: () => SpecializationBloc(
        getSpecializationsUsecase: mockGetSpecializationsUsecase),
    act: (bloc) => bloc.add(const SpecializationRequested()),
    expect: () => [
      const SpecializationState(status: SpecializationStatus.loading),
      SpecializationState(
        status: SpecializationStatus.failure,
        errorMessage: tFailure.userMessage,
      ),
    ],
  );

  blocTest<SpecializationBloc, SpecializationState>(
    'selecting a chip sets selectedId, re-selecting the same chip clears it',
    build: () => SpecializationBloc(
        getSpecializationsUsecase: mockGetSpecializationsUsecase),
    act: (bloc) => bloc
      ..add(const SpecializationSelected('spec_01'))
      ..add(const SpecializationSelected('spec_01')),
    expect: () => [
      const SpecializationState(selectedId: 'spec_01'),
      const SpecializationState(),
    ],
  );
}
