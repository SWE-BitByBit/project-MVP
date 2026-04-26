import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/safe_place_dto.dart';

void main() {
  group('SafePlace e SafePlaceDTO Test', () {
    final Map<String, dynamic> mockJson = {
      'id': '1',
      'name': 'Centro Sicuro',
      'address': 'Via Roma',
      'latitude': 45.4, // Intero gestito come num
      'longitude': 11.8,
      'category': 'Supporto'
    };

    final SafePlace mockPlace = const SafePlace(
      id: '1',
      name: 'Centro Sicuro',
      address: 'Via Roma',
      latitude: 45.4,
      longitude: 11.8,
      category: 'Supporto',
    );

    test('fromJson converte correttamente il JSON in un SafePlace', () {
      // Act
      final result = SafePlaceDTO.fromJson(mockJson);

      // Assert
      expect(result.id, '1');
      expect(result.name, 'Centro Sicuro');
      expect(result.latitude, 45.4); // Verifica conversione toDouble()
      expect(result.category, 'Supporto');
    });

    test('toJson converte correttamente un SafePlace in JSON', () {
      // Act
      final result = SafePlaceDTO.toJson(mockPlace);

      // Assert
      expect(result, mockJson);
    });
  });
}