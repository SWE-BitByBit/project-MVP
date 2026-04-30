import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/safe_place_service.dart';

import '../../../testing/mocks/network/mock_api_client.dart';

void main() {
  late SafePlaceService safePlaceService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    safePlaceService = SafePlaceService(apiClient: mockApiClient);
  });

  final List<dynamic> tSafePlacesList = [
    {
      "marker_id": "1",
      "name": "Ospedale Maggiore",
      "address": "Via Roma 1",
      "latitude": "45.0",
      "longitude": "9.0",
      "category": "ospedale"
    },
    {
      "marker_id": "2",
      "name": "Questura",
      "address": "Piazza Repubblica 2",
      "latitude": "45.1",
      "longitude": "9.1",
      "category": "polizia"
    }
  ];

  group('fetchSafePlaces', () {
    test('should return map with data containing the list when ApiClient returns a List', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => tSafePlacesList);

      // act
      final result = await safePlaceService.fetchSafePlaces();

      // assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['data'], equals(tSafePlacesList));
      verify(() => mockApiClient.get('/safe-places')).called(1);
    });

    test('should return map with empty data list when ApiClient returns a Map instead of List', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => {"error": "not a list"});

      // act
      final result = await safePlaceService.fetchSafePlaces();

      // assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['data'], isEmpty);
      verify(() => mockApiClient.get('/safe-places')).called(1);
    });

    test('should return map with empty data list when ApiClient returns null', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => null);

      // act
      final result = await safePlaceService.fetchSafePlaces();

      // assert
      expect(result['data'], isEmpty);
      verify(() => mockApiClient.get('/safe-places')).called(1);
    });

    test('should rethrow exception if ApiClient throws', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenThrow(Exception('Network error'));

      // act & assert
      expect(() => safePlaceService.fetchSafePlaces(), throwsException);
    });
  });
}