import 'package:careplus/core/error/failures.dart';
import 'package:careplus/core/storage/token_manager.dart';
import 'package:careplus/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:careplus/features/auth/data/models/auth_response_model.dart';
import 'package:careplus/features/auth/data/models/register_response_model.dart';
import 'package:careplus/features/auth/data/models/user_model.dart';
import 'package:careplus/features/auth/data/repository/auth_repo_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenManager extends Mock implements TokenManager {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late MockTokenManager mockTokenManager;
  late AuthRepositoryImpl repository;

  const tUserModel = UserModel(
    id: 'usr_001',
    name: 'Minhajul Islam',
    email: 'minhajul.islam@example.com',
    phone: '+8801711223344',
    photoUrl: '',
    dateOfBirth: '',
    gender: '',
    bloodGroup: '',
    address: '',
  );

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    mockTokenManager = MockTokenManager();
    repository = AuthRepositoryImpl(
      authRemoteDataSource: mockDataSource,
      tokenManager: mockTokenManager,
    );
  });

  group('login', () {
    test('saves the token and user id, and returns the User on success',
        () async {
      when(() => mockDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const AuthResponseModel(
            accessToken: 'mock.token.usr_001',
            user: tUserModel,
          ));
      when(() => mockTokenManager.saveTokens(accessToken: any(named: 'accessToken')))
          .thenAnswer((_) async {});
      when(() => mockTokenManager.saveUserId(any())).thenAnswer((_) async {});

      final result = await repository.login(
        email: 'minhajul.islam@example.com',
        password: 'secret123',
      );

      expect(result.isRight(), true);
      result.match((_) => fail('expected Right'), (user) {
        expect(user.id, 'usr_001');
      });
      verify(() => mockTokenManager.saveTokens(accessToken: 'mock.token.usr_001'))
          .called(1);
      verify(() => mockTokenManager.saveUserId('usr_001')).called(1);
    });

    test('maps InvalidCredentialsException to an AuthFailure', () async {
      when(() => mockDataSource.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const InvalidCredentialsException());

      final result = await repository.login(
        email: 'minhajul.islam@example.com',
        password: 'wrong',
      );

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<AuthFailure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  group('register', () {
    test('maps EmailAlreadyInUseException to a ClientFailure', () async {
      when(() => mockDataSource.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenThrow(const EmailAlreadyInUseException());

      final result = await repository.register(
        name: 'Duplicate',
        email: 'minhajul.islam@example.com',
        password: 'whatever',
        phone: '+8801000000000',
      );

      expect(result.isLeft(), true);
      result.match(
        (failure) => expect(failure, isA<ClientFailure>()),
        (_) => fail('expected Left'),
      );
    });

    test('forwards a successful RegisterResponseModel as a RegisterResult',
        () async {
      when(() => mockDataSource.register(
            name: any(named: 'name'),
            email: any(named: 'email'),
            phone: any(named: 'phone'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const RegisterResponseModel(
            message: 'Account created successfully.',
            userId: 'usr_002',
            requiresOtp: true,
          ));

      final result = await repository.register(
        name: 'New Person',
        email: 'new.person@example.com',
        password: 'newpass123',
        phone: '+8801999999999',
      );

      expect(result.isRight(), true);
      result.match((_) => fail('expected Right'), (registerResult) {
        expect(registerResult.userId, 'usr_002');
        expect(registerResult.requiresOtp, true);
      });
    });
  });

  group('getCurrentUser', () {
    test('looks the user up using the id stored by TokenManager', () async {
      when(() => mockTokenManager.getUserId()).thenAnswer((_) async => 'usr_001');
      when(() => mockDataSource.getCurrentUser(userId: any(named: 'userId')))
          .thenAnswer((_) async => tUserModel);

      final result = await repository.getCurrentUser();

      expect(result.isRight(), true);
      verify(() => mockDataSource.getCurrentUser(userId: 'usr_001')).called(1);
    });
  });
}
