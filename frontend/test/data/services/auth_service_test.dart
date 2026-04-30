import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/auth_service.dart';

import '../../../testing/mocks/network/mock_http_client.dart';

void main() {
  // Inizializzazione obbligatoria per test che usano canali platform o binding
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;
  late MockHttpClient mockHttpClient;

  setUpAll(() async {
    // Caricamento variabili d'ambiente fittizie per evitare NotInitializedError da AppConfig
    dotenv.loadFromString(envString: '''
      COGNITO_DOMAIN=auth.test.com
      COGNITO_CLIENT_ID=test_client_id
      COGNITO_CLIENT_SECRET=test_client_secret
    ''');

    registerFallbackValue(Uri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    authService = AuthService(httpClient: mockHttpClient);
  });

  void mockFlutterWebAuth2({String? returnUrl, PlatformException? error}) {
    const channel = MethodChannel('flutter_web_auth_2');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'authenticate') {
        if (error != null) throw error;
        return returnUrl;
      }
      return null;
    });
  }

  tearDown(() {
    const channel = MethodChannel('flutter_web_auth_2');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  final Map<String, dynamic> tTokenResponseMap = {
    "access_token": "eyJhbGciOiJIUzI1...",
    "id_token": "eyJhbGciOiJIUzI1...",
    "refresh_token": "mock_refresh_token_123",
    "expires_in": 3600,
    "token_type": "Bearer"
  };

  group('login', () {
    test('should return token map when web auth succeeds and HTTP returns 200', () async {
      mockFlutterWebAuth2(returnUrl: 'com.bitbybit.appcheproteggeetrasforma://callback?code=mock_code');

      when(() => mockHttpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(tTokenResponseMap), 200));

      final result = await authService.login();

      expect(result['access_token'], tTokenResponseMap['access_token']);
      verify(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body'))).called(1);
    });

    test('should throw Exception when return url does not contain code', () async {
      mockFlutterWebAuth2(returnUrl: 'com.bitbybit.appcheproteggeetrasforma://callback?error=access_denied');

      expect(() => authService.login(), throwsException);
    });

    test('should throw Exception when HTTP call for token fails (not 200)', () async {
      mockFlutterWebAuth2(returnUrl: 'com.bitbybit.appcheproteggeetrasforma://callback?code=mock_code');
      when(() => mockHttpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response('Error', 400));

      expect(() => authService.login(), throwsException);
    });
  });

  group('logout', () {
    test('should complete without error even if web auth throws (typical for logout redirect)', () async {
      mockFlutterWebAuth2(error: PlatformException(code: 'CANCELED'));

      await authService.logout();

      // Passa se non solleva eccezioni
    });
  });

  group('refreshToken', () {
    const tRefreshToken = 'old_token';

    test('should return new tokens when HTTP 200', () async {
      when(() => mockHttpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response(jsonEncode(tTokenResponseMap), 200));

      final result = await authService.refreshToken(tRefreshToken);

      expect(result['access_token'], tTokenResponseMap['access_token']);
      expect(result['refresh_token'], tTokenResponseMap['refresh_token']);
    });

    test('should throw Exception when refresh fails', () async {
      when(() => mockHttpClient.post(
        any(),
        headers: any(named: 'headers'),
        body: any(named: 'body'),
      )).thenAnswer((_) async => http.Response('Invalid', 401));

      expect(() => authService.refreshToken(tRefreshToken), throwsException);
    });
  });
}