import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/usecase/usecase.dart';
import 'package:careplus/features/auth/domain/entity/user.dart';
import 'package:careplus/features/auth/domain/repository/auth_repo.dart';
import 'package:careplus/features/profile/domain/usecase/get_profile_usecase.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late GetProfileUsecase usecase;

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

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = GetProfileUsecase(authRepository: mockAuthRepository);
  });

  test('returns Right(User) when repository call succeeds', () async {
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const Right(tUser));

    final result = await usecase(const NoParams());

    expect(result, const Right<Failure, User>(tUser));
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('returns Left(Failure) when repository call fails', () async {
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => const Left(tFailure));

    final result = await usecase(const NoParams());

    expect(result, const Left<Failure, User>(tFailure));
    verify(() => mockAuthRepository.getCurrentUser()).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
