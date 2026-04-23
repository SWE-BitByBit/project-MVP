import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mvp_app_protegge_e_trasforma/data/network/api_exception.dart';
import 'package:mvp_app_protegge_e_trasforma/data/network/http_api_client.dart';

void main() {
  const String testBaseUrl = 'https://api.test.com';

  group('HttpApiClient', () {
    test('Esegue una GET e decodifica il JSON correttamente (200 OK)', () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'message': 'Success'}), 200);
      });

      final apiClient = HttpApiClient(
        baseUrl: testBaseUrl,
        httpClient: mockClient,
      );

      // Act: Usiamo requiresAuth (con la "s"!)
      final result = await apiClient.get('/test-endpoint', requiresAuth: false);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['message'], 'Success');
    });

    test('Lancia un\'ApiException se il server risponde con un errore (es. 404)', () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final apiClient = HttpApiClient(
        baseUrl: testBaseUrl,
        httpClient: mockClient,
      );

      // Act & Assert
      expect(
            () => apiClient.get('/wrong-endpoint', requiresAuth: false),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });

    test('Inietta correttamente il Bearer Token negli header se requiresAuth è true', () async {
      // Arrange
      final mockClient = MockClient((request) async {
        // Il test verifica che il token sia stato effettivamente inserito!
        expect(request.headers['Authorization'], 'Bearer MOCK_TOKEN_123');
        return http.Response(jsonEncode({'status': 'ok'}), 200);
      });

      final apiClient = HttpApiClient(
        baseUrl: testBaseUrl,
        httpClient: mockClient,
        getToken: () async => 'MOCK_TOKEN_123',
      );

      // Act: calls get with requiresAuth = true (che è il default)
      await apiClient.get('/protected', requiresAuth: true);

    });
  });
}