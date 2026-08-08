import 'package:careplus/core/network/mock_api_client.dart';
import 'package:careplus/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockMockApiClient extends Mock implements MockApiClient {}

void main() {
  late MockMockApiClient mockApiClient;
  late AuthRemoteDataSourcImpl dataSource;

  final tUsersJson = {
    'users': [
      {
        'id': 'usr_001',
        'name': 'Minhajul Islam',
        'email': 'minhajul.islam@example.com',
        'phone': '+8801711223344',
        'password': 'secret123',
        'photoUrl': '',
        'dateOfBirth': '',
        'gender': '',
        'bloodGroup': '',
        'address': '',
        'createdAt': '2025-01-14T10:00:00Z',
      },
    ],
  };

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockApiClient = MockMockApiClient();
    dataSource = AuthRemoteDataSourcImpl(apiClient: mockApiClient);
  });

  group('login', () {
    test('returns an AuthResponseModel when email/password match a stored user',
        () async {
      when(() => mockApiClient.load('users.json'))
          .thenAnswer((_) async => tUsersJson);

      final result = await dataSource.login(
        email: 'minhajul.islam@example.com',
        password: 'secret123',
      );

      expect(result.user.id, 'usr_001');
      expect(result.accessToken, 'mock.token.usr_001');
    });

    test('throws InvalidCredentialsException when nothing matches', () async {
      when(() => mockApiClient.load('users.json'))
          .thenAnswer((_) async => tUsersJson);

      expect(
        () => dataSource.login(
          email: 'minhajul.islam@example.com',
          password: 'wrong-password',
        ),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });
  });

  group('register', () {
    test('appends a new user record and returns requiresOtp true', () async {
      when(() => mockApiClient.load('users.json'))
          .thenAnswer((_) async => tUsersJson);
      when(() => mockApiClient.save('users.json', any()))
          .thenAnswer((_) async {});

      final result = await dataSource.register(
        name: 'New Person',
        email: 'new.person@example.com',
        phone: '+8801999999999',
        password: 'newpass123',
      );

      expect(result.requiresOtp, true);

      final captured =
          verify(() => mockApiClient.save('users.json', captureAny()))
              .captured;
      final saved = captured.single as Map<String, dynamic>;
      final users = saved['users'] as List;
      expect(users.length, 2);
      expect((users.last as Map)['email'], 'new.person@example.com');
    });

    test('throws EmailAlreadyInUseException for a duplicate email', () async {
      when(() => mockApiClient.load('users.json'))
          .thenAnswer((_) async => tUsersJson);

      expect(
        () => dataSource.register(
          name: 'Duplicate',
          email: 'minhajul.islam@example.com',
          phone: '+8801000000000',
          password: 'whatever',
        ),
        throwsA(isA<EmailAlreadyInUseException>()),
      );
    });
  });
}
