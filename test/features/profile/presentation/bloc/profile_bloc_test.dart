import 'package:bloc_test/bloc_test.dart';
import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/auth/domain/entity/user.dart';
import 'package:careplus/features/profile/domain/usecase/get_profile_usecase.dart';
import 'package:careplus/features/profile/domain/usecase/update_profile_usecase.dart';
import 'package:careplus/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:careplus/features/profile/presentation/bloc/profile_event.dart';
import 'package:careplus/features/profile/presentation/bloc/profile_state.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProfileUsecase extends Mock implements GetProfileUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

void main() {
  late MockGetProfileUsecase mockGetProfileUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;

  const tUser = User(
    id: 'usr_001',
    name: 'Minhajul Islam',
    email: 'minhajul.islam@example.com',
    phone: '+8801711223344',
    photoUrl: 'https://i.pravatar.cc/150?img=12',
    dateOfBirth: '1996-04-12',
    gender: 'male',
    bloodGroup: 'B+',
    address: 'Road 12, Banani, Dhaka',
  );
  const tFailure = UnknownFailure();

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetProfileUsecase = MockGetProfileUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
  });

  blocTest<ProfileBloc, ProfileState>(
    'emits [loading, success] when ProfileRequested succeeds',
    setUp: () {
      when(() => mockGetProfileUsecase(any()))
          .thenAnswer((_) async => const Right(tUser));
    },
    build: () => ProfileBloc(
      getProfileUsecase: mockGetProfileUsecase,
      updateProfileUsecase: mockUpdateProfileUsecase,
    ),
    act: (bloc) => bloc.add(const ProfileRequested()),
    expect: () => [
      const ProfileState(status: ProfileStatus.loading),
      const ProfileState(status: ProfileStatus.success, user: tUser),
    ],
  );

  blocTest<ProfileBloc, ProfileState>(
    'emits [loading, failure] when ProfileRequested fails',
    setUp: () {
      when(() => mockGetProfileUsecase(any()))
          .thenAnswer((_) async => const Left(tFailure));
    },
    build: () => ProfileBloc(
      getProfileUsecase: mockGetProfileUsecase,
      updateProfileUsecase: mockUpdateProfileUsecase,
    ),
    act: (bloc) => bloc.add(const ProfileRequested()),
    expect: () => [
      const ProfileState(status: ProfileStatus.loading),
      ProfileState(
        status: ProfileStatus.failure,
        errorMessage: tFailure.userMessage,
      ),
    ],
  );
}
