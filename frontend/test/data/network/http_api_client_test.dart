import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:mvp_app_protegge_e_trasforma/data/network/http_api_client.dart';
import 'package:mvp_app_protegge_e_trasforma/data/network/api_exception.dart';

import '../../../testing/mocks/network/mock_http_client.dart';

void main() {
  late HttpApiClient apiClient;
  late MockHttpClient mockHttpClient;
  final String baseUrl = 'https://api.example.com';

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://api.example.com'));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    apiClient = HttpApiClient(
      baseUrl: baseUrl,
      httpClient: mockHttpClient,
      getToken: () async => 'fake_token_123',
    );
  });

  group('HttpApiClient Tests', () {
    group('Headers & Auth Injection', () {
      test('dovrebbe includere gli header di default e il token Bearer se requiresAuth è true', () async {
        // Arrange
        final uri = Uri.parse('$baseUrl/test');
        when(() => mockHttpClient.get(uri, headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await apiClient.get('/test', requiresAuth: true);

        // Assert
        final captured = verify(() => mockHttpClient.get(uri, headers: captureAny(named: 'headers'))).captured;
        final headers = captured.first as Map<String, String>;

        expect(headers['Content-Type'], 'application/json');
        expect(headers['Accept'], 'application/json');
        expect(headers['Authorization'], 'Bearer fake_token_123');
      });

      test('NON dovrebbe includere il token Bearer se requiresAuth è false', () async {
        // Arrange
        final uri = Uri.parse('$baseUrl/test');
        when(() => mockHttpClient.get(uri, headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await apiClient.get('/test', requiresAuth: false);

        // Assert
        final captured = verify(() => mockHttpClient.get(uri, headers: captureAny(named: 'headers'))).captured;
        final headers = captured.first as Map<String, String>;

        expect(headers.containsKey('Authorization'), isFalse);
      });

      test('dovrebbe fondere gli header custom con quelli di default', () async {
        // Arrange
        final uri = Uri.parse('$baseUrl/test');
        when(() => mockHttpClient.get(uri, headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('{}', 200));

        // Act
        await apiClient.get('/test', headers: {'X-Custom-Header': 'value'}, requiresAuth: false);

        // Assert
        final captured = verify(() => mockHttpClient.get(uri, headers: captureAny(named: 'headers'))).captured;
        final headers = captured.first as Map<String, String>;

        expect(headers['Content-Type'], 'application/json');
        expect(headers['X-Custom-Header'], 'value');
      });
    });

    group('Response Handling', () {
      test('dovrebbe parsare il JSON e restituire il body per status code 200-299', () async {
        // Arrange
        final uri = Uri.parse('$baseUrl/data');
        final responseBody = {'id': 1, 'name': 'Test'};
        when(() => mockHttpClient.get(uri, headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(jsonEncode(responseBody), 200));

        // Act
        final result = await apiClient.get('/data');

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['id'], 1);
        expect(result['name'], 'Test');
      });

      test('dovrebbe restituire null se il body della risposta 2XX è vuoto', () async {
        // Arrange
        final uri = Uri.parse('$baseUrl/empty');
        when(() => mockHttpClient.get(uri, headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('', 204));

        // Act
        final result = await apiClient.get('/empty');

        // Assert
        expect(result, isNull);
      });

      test('dovrebbe lanciare ApiException per status code fuori da 200-299', () async {
        // Arrange
        final uri = Uri.parse('$baseUrl/error');
        when(() => mockHttpClient.get(uri, headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('Not Found', 404));

        // Act & Assert
        expect(
              () => apiClient.get('/error'),
          throwsA(
            isA<ApiException>()
                .having((e) => e.statusCode, 'statusCode', 404)
                .having((e) => e.message, 'message', contains('Not Found')),
          ),
        );
      });
    });

    group('HTTP Methods', () {
      final testBody = {'key': 'value'};
      final encodedBody = jsonEncode(testBody);

      test('post() dovrebbe inviare il body codificato in JSON', () async {
        // Arrange
        final uri = Uri.parse('$baseUrl/post-endpoint');
        when(() => mockHttpClient.post(uri, headers: any(named: 'headers'), body: any(named: 'body')))
            .thenAnswer((_) async => http.Response('{"success": true}', 201));

        // Act
        final result = await apiClient.post('/post-endpoint', body: testBody);

        // Assert
        verify(() => mockHttpClient.post(uri, headers: any(named: 'headers'), body: encodedBody)).called(1);
        expect(result['success'], isTrue);
      });

      test('put() dovrebbe inviare il body codificato in JSON', () async {
        // Arrange
        final uri = Uri.parse('$baseUrl/put-endpoint');
        when(() => mockHttpClient.put(uri, headers: any(named: 'headers'), body: any(named: 'body')))
            .thenAnswer((_) async => http.Response('{"updated": true}', 200));

        // Act
        final result = await apiClient.put('/put-endpoint', body: testBody);

        // Assert
        verify(() => mockHttpClient.put(uri, headers: any(named: 'headers'), body: encodedBody)).called(1);
        expect(result['updated'], isTrue);
      });

      test('delete() dovrebbe effettuare la chiamata corretta', () async {
        // Arrange
        final uri = Uri.parse('$baseUrl/delete-endpoint');
        when(() => mockHttpClient.delete(uri, headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('', 204));

        // Act
        final result = await apiClient.delete('/delete-endpoint');

        // Assert
        verify(() => mockHttpClient.delete(uri, headers: any(named: 'headers'))).called(1);
        expect(result, isNull);
      });
    });
  });
}