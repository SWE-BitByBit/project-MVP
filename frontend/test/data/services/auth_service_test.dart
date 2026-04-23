import 'dart:convert';
import 'package:flutter/services.dart'; // Per il mock del MethodChannel
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import necessario
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Inizializziamo l'ambiente una sola volta per tutti i test in questo file
  setUpAll(() async {
    // FIX 1: Inizializziamo dotenv con valori finti per i test
    // testLoad permette di caricare variabili senza leggere un file fisico .env
    dotenv.loadFromString(envString: '''
COGNITO_DOMAIN=test.auth.com
CLIENT_ID=test_id
CLIENT_SECRET=test_secret
REDIRECT_URI=test://callback
CALLBACK_SCHEME=test
''');

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('flutter_web_auth_2'),
          (methodCall) async {
        if (methodCall.method == 'authenticate') {
          return 'test://callback?code=mock_auth_code';
        }
        return null;
      },
    );
  });

  group('AuthService Test', () {
    test('login() restituisce i token se l\'API risponde 200', () async {
      final mockResponse = {
        'access_token': 'test_access',
        'id_token': 'header.${base64Url.encode(utf8.encode('{"email":"test@test.com"}'))}.signature',
        'refresh_token': 'test_refresh',
      };

      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode(mockResponse), 200);
      });

      final authService = AuthService(httpClient: mockClient);

      final result = await authService.login();

      expect(result['access_token'], 'test_access');
    });

    test('login() lancia un\'eccezione se l\'API risponde 400', () async {
      final mockClient = MockClient((request) async => http.Response('Error', 400));
      final authService = AuthService(httpClient: mockClient);

      expect(() => authService.login(), throwsException);
    });


    test('logout() viene eseguito senza errori', () async {
      final authService = AuthService(); // Non serve il mock per un metodo vuoto/locale

      // Act & Assert
      // Assicuriamoci che non lanci eccezioni
      await expectLater(authService.logout(), completes);
    });
  });
}