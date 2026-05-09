import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/material_service.dart';

import '../../../testing/mocks/network/mock_api_client.dart';

void main() {
  late MaterialService materialService;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    materialService = MaterialService(apiClient: mockApiClient);
  });

  final List<dynamic> tMaterialsList = [
    {
      "resource_id": "1",
      "title": "Centro Antiviolenza",
      "type": "community"
    },
    {
      "resource_id": "2",
      "title": "Codice Rosso",
      "type": "law"
    }
  ];

  group('fetchMaterials', () {
    test('should return map with data containing the list when ApiClient returns a List', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => tMaterialsList);

      // act
      final result = await materialService.fetchMaterials();

      // assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['data'], equals(tMaterialsList));
      verify(() => mockApiClient.get('/materials')).called(1);
    });

    test('should return map with empty data list when ApiClient returns a Map instead of List', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => {"error": "not a list"});

      // act
      final result = await materialService.fetchMaterials();

      // assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['data'], isEmpty);
      verify(() => mockApiClient.get('/materials')).called(1);
    });

    test('should return map with empty data list when ApiClient returns null', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenAnswer((_) async => null);

      // act
      final result = await materialService.fetchMaterials();

      // assert
      expect(result['data'], isEmpty);
    });

    test('should rethrow exception if ApiClient throws', () async {
      // arrange
      when(() => mockApiClient.get(any())).thenThrow(Exception('Network error'));

      // act & assert
      expect(() => materialService.fetchMaterials(), throwsException);
    });
  });
}