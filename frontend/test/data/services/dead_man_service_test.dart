import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/dead_man_service.dart';

import '../../../testing/mocks/network/mock_api_client.dart';

void main() {
  late DeadManService deadManService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    deadManService = DeadManService(apiClient: mockApiClient);
  });

  final Map<String, dynamic> tSettingsResponse = {
    "is_active": true,
    "first_inactivity_timer": 5,
    "second_inactivity_timer": 3,
    "message_subject": "Allarme di sicurezza",
    "message_body":
        "Se ricevi questo messaggio, significa che non ho fatto il check-in.",
  };

  group('fetchSettings', () {
    test('should perform GET request on /dms_settings and return data map', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => tSettingsResponse);

      final result = await deadManService.fetchSettings();

      expect(result, equals(tSettingsResponse));
      verify(() => mockApiClient.get('/dms_settings')).called(1);
    });

    test('should return empty map if the response is not a Map (e.g. List)', () async {
      when(() => mockApiClient.get(any())).thenAnswer((_) async => [1, 2, 3]);

      final result = await deadManService.fetchSettings();

      expect(result, equals({}));
      verify(() => mockApiClient.get('/dms_settings')).called(1);
    });

    test('should rethrow exception if ApiClient throws', () async {
      when(() => mockApiClient.get(any())).thenThrow(Exception('Network error'));

      expect(() => deadManService.fetchSettings(), throwsException);
    });
  });

  group('saveSettings', () {
    test('should perform PUT request on /dms_settings with settings data', () async {
      when(() => mockApiClient.put(any(), body: any(named: 'body')))
          .thenAnswer((_) async => {});

      await deadManService.saveSettings(tSettingsResponse);

      verify(() => mockApiClient.put('/dms_settings', body: tSettingsResponse)).called(1);
    });

    test('should rethrow exception if ApiClient put throws', () async {
      when(() => mockApiClient.put(any(), body: any(named: 'body')))
          .thenThrow(Exception('Server error'));

      expect(() => deadManService.saveSettings(tSettingsResponse), throwsException);
    });
  });

  group('sendHeartbeat', () {
    test('should perform POST request on /dms_settings/heartbeat', () async {
      when(() => mockApiClient.post(any(), body: any(named: 'body')))
          .thenAnswer((_) async => {});

      await deadManService.sendHeartbeat();

      verify(() => mockApiClient.post('/dms_settings/heartbeat')).called(1);
    });

    test('should rethrow exception if heartbeat API call fails', () async {
      when(() => mockApiClient.post(any(), body: any(named: 'body')))
          .thenThrow(Exception('Timeout'));

      expect(() => deadManService.sendHeartbeat(), throwsException);
    });
  });
}
