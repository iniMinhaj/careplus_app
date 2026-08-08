import 'package:bloc_test/bloc_test.dart';
import 'package:careplus/core/error/failures.dart';
import 'package:careplus/features/home/domain/entity/doctor.dart';
import 'package:careplus/features/home/domain/usecase/get_doctors_usecase.dart';
import 'package:careplus/features/home/presentation/bloc/doctor_list/doctor_list_bloc.dart';
import 'package:careplus/features/home/presentation/bloc/doctor_list/doctor_list_event.dart';
import 'package:careplus/features/home/presentation/bloc/doctor_list/doctor_list_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

class MockGetDoctorsUsecase extends Mock implements GetDoctorsUsecase {}

void main() {
  late MockGetDoctorsUsecase mockGetDoctorsUsecase;

  const tDoctorA = Doctor(
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
  );
  const tDoctorB = Doctor(
    id: 'doc_02',
    name: 'Dr. Kamal Hossain',
    specializationId: 'spec_02',
    specializationName: 'Dermatologist',
    photoUrl: '',
    experienceYears: 5,
    rating: 4.2,
    reviewCount: 60,
    consultationFee: 800,
    currency: 'BDT',
    hospital: 'United Hospital',
    location: 'Dhaka',
    isAvailableToday: false,
  );
  const tFailure = UnknownFailure();

  setUpAll(() {
    registerFallbackValue(const GetDoctorsParams());
  });

  setUp(() {
    mockGetDoctorsUsecase = MockGetDoctorsUsecase();
  });

  blocTest<DoctorListBloc, DoctorListState>(
    'emits [loading, success] when DoctorListRequested succeeds',
    setUp: () {
      when(() => mockGetDoctorsUsecase(any()))
          .thenAnswer((_) async => const Right([tDoctorA, tDoctorB]));
    },
    build: () => DoctorListBloc(getDoctorsUsecase: mockGetDoctorsUsecase),
    act: (bloc) => bloc.add(const DoctorListRequested()),
    expect: () => [
      const DoctorListState(status: DoctorListStatus.loading),
      const DoctorListState(
        status: DoctorListStatus.success,
        doctors: [tDoctorA, tDoctorB],
      ),
    ],
  );

  blocTest<DoctorListBloc, DoctorListState>(
    'emits empty status when the result list is empty',
    setUp: () {
      when(() => mockGetDoctorsUsecase(any()))
          .thenAnswer((_) async => const Right([]));
    },
    build: () => DoctorListBloc(getDoctorsUsecase: mockGetDoctorsUsecase),
    act: (bloc) => bloc.add(const DoctorListRequested()),
    expect: () => [
      const DoctorListState(status: DoctorListStatus.loading),
      const DoctorListState(status: DoctorListStatus.empty),
    ],
  );

  blocTest<DoctorListBloc, DoctorListState>(
    'emits [loading, failure] when the usecase fails',
    setUp: () {
      when(() => mockGetDoctorsUsecase(any()))
          .thenAnswer((_) async => const Left(tFailure));
    },
    build: () => DoctorListBloc(getDoctorsUsecase: mockGetDoctorsUsecase),
    act: (bloc) => bloc.add(const DoctorListRequested()),
    expect: () => [
      const DoctorListState(status: DoctorListStatus.loading),
      DoctorListState(
        status: DoctorListStatus.failure,
        errorMessage: tFailure.userMessage,
      ),
    ],
  );

  blocTest<DoctorListBloc, DoctorListState>(
    'debounces rapid DoctorSearchChanged events into a single fetch',
    setUp: () {
      when(() => mockGetDoctorsUsecase(any()))
          .thenAnswer((_) async => const Right([tDoctorA]));
    },
    build: () => DoctorListBloc(getDoctorsUsecase: mockGetDoctorsUsecase),
    act: (bloc) => bloc
      ..add(const DoctorSearchChanged('a'))
      ..add(const DoctorSearchChanged('an'))
      ..add(const DoctorSearchChanged('ani')),
    wait: const Duration(milliseconds: 500),
    verify: (_) {
      verify(() => mockGetDoctorsUsecase(
            const GetDoctorsParams(query: 'ani'),
          )).called(1);
    },
  );

  blocTest<DoctorListBloc, DoctorListState>(
    'discards a stale response superseded by a newer request',
    setUp: () {
      // First call (triggered by DoctorListRequested) resolves slowly.
      // Second call (triggered by the specialization filter change)
      // resolves fast — only its result should survive.
      var callCount = 0;
      when(() => mockGetDoctorsUsecase(any())).thenAnswer((invocation) async {
        callCount++;
        if (callCount == 1) {
          await Future.delayed(const Duration(milliseconds: 100));
          return const Right([tDoctorA]);
        }
        return const Right([tDoctorB]);
      });
    },
    build: () => DoctorListBloc(getDoctorsUsecase: mockGetDoctorsUsecase),
    act: (bloc) async {
      bloc.add(const DoctorListRequested());
      await Future.delayed(const Duration(milliseconds: 10));
      bloc.add(const DoctorSpecializationFilterChanged('spec_02'));
    },
    wait: const Duration(milliseconds: 200),
    expect: () => [
      const DoctorListState(status: DoctorListStatus.loading),
      const DoctorListState(
        status: DoctorListStatus.loading,
        specializationId: 'spec_02',
      ),
      const DoctorListState(
        status: DoctorListStatus.success,
        specializationId: 'spec_02',
        doctors: [tDoctorB],
      ),
    ],
  );
}
