import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';

import '../../../testing/mocks/network/mock_api_client.dart';

void main() {
  late DiaryAccountService service;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    service = DiaryAccountService(apiClient: mockApiClient);
  });

  group('validateDiaryPassword', () {
    final tLoginResponse = {
      "token": "valid_diary_token_123",
      "diary_type": "REAL_DIARY"
    };

    test('should perform POST request on /diary/auth/login and return response map', () async {
      // arrange
      when(() => mockApiClient.post(
        any(),
        body: any(named: 'body'),
        requiresAuth: any(named: 'requiresAuth'),
      )).thenAnswer((_) async => tLoginResponse);

      // act
      final result = await service.validateDiaryPassword('my_password');

      // assert
      expect(result, equals(tLoginResponse));
      verify(() => mockApiClient.post(
        '/diary/auth/login',
        body: {'password': 'my_password'},
        requiresAuth: true,
      )).called(1);
    });

    test('should rethrow exception if ApiClient throws', () async {
      // arrange
      when(() => mockApiClient.post(
        any(),
        body: any(named: 'body'),
        requiresAuth: any(named: 'requiresAuth'),
      )).thenThrow(Exception('Invalid password'));

      // act & assert
      expect(() => service.validateDiaryPassword('wrong_password'), throwsException);
    });
  });

  group('setPassword', () {
    final tSetPasswordResponse = {"status": "success"};

    test('should perform POST request with old_password when provided', () async {
      // arrange
      when(() => mockApiClient.post(
        any(),
        body: any(named: 'body'),
        requiresAuth: any(named: 'requiresAuth'),
      )).thenAnswer((_) async => tSetPasswordResponse);

      // act
      final result = await service.setPassword('old_pass', 'new_pass', DiaryType.real_diary);

      // assert
      expect(result, equals(tSetPasswordResponse));
      verify(() => mockApiClient.post(
        '/diary/auth/set_password',
        headers: any(named: 'headers'),
        body: {
          'previous_password': 'old_pass',
          'password': 'new_pass',
          'diary_type': 'real_diary',
        },
        requiresAuth: true,
      )).called(1);
    });

    test('should perform POST request without old_password when null', () async {
      // arrange
      when(() => mockApiClient.post(
        any(),
        body: any(named: 'body'),
        requiresAuth: any(named: 'requiresAuth'),
      )).thenAnswer((_) async => tSetPasswordResponse);

      // act
      final result = await service.setPassword(null, 'new_pass', DiaryType.fake_diary);

      // assert
      expect(result, equals(tSetPasswordResponse));
      verify(() => mockApiClient.post(
        '/diary/auth/set_password',
        headers: any(named: 'headers'),
        body: {
          'password': 'new_pass',
          'diary_type': 'fake_diary',
        },
        requiresAuth: true,
      )).called(1);
    });
  });

  group('checkHasRealPassword', () {
    test('should return true when API returns has_password as true', () async {
      // arrange
      when(() => mockApiClient.get(
        any(),
        headers: any(named: 'headers'),
        requiresAuth: any(named: 'requiresAuth'),
      )).thenAnswer((_) async => {"has_real_password": true});

      // act
      final result = await service.checkHasRealPassword();

      // assert
      expect(result, isTrue);
      verify(() => mockApiClient.get('/diary/auth/status', requiresAuth: true)).called(1);
    });

    test('should return false when API returns has_password as false', () async {
      // arrange
      when(() => mockApiClient.get(
        any(),
        headers: any(named: 'headers'),
        requiresAuth: any(named: 'requiresAuth'),
      )).thenAnswer((_) async => {"has_real_password": false});

      // act
      final result = await service.checkHasRealPassword();

      // assert
      expect(result, isFalse);
    });

    test('should catch exception and return false on error (e.g., 404)', () async {
      // arrange
      when(() => mockApiClient.get(
        any(),
        headers: any(named: 'headers'),
        requiresAuth: any(named: 'requiresAuth'),
      )).thenThrow(Exception('404 Not Found'));

      // act
      final result = await service.checkHasRealPassword();

      // assert
      expect(result, isFalse);
    });
  });
}