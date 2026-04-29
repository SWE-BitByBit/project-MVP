import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/safe_place_dto.dart';

void main() {
  /// Test unitari per [SafePlaceDTO].
  /// 
  /// Verifica la corretta conversione dei dati tra il formato JSON
  /// e l'oggetto di dominio [SafePlace].
  group('SafePlace e SafePlaceDTO Test', () {
    final Map<String, dynamic> mockJson = {
      'marker_id': '1',
      'name': 'Centro Sicuro',
      'address': 'Via Roma',
      'latitude': 45.4,
      'longitude': 11.8,
      'category': 'Supporto'
    };

    const SafePlace mockPlace = SafePlace(
      id: '1',
      name: 'Centro Sicuro',
      address: 'Via Roma',
      latitude: 45.4,
      longitude: 11.8,
      category: 'Supporto',
    );

    /// Verifica che il metodo fromJson converta correttamente
    /// una mappa JSON valida in un'istanza di [SafePlace].
    test('fromJson converte correttamente il JSON in un SafePlace', () {
      final result = SafePlaceDTO.fromJson(mockJson);

      expect(result.id, '1');
      expect(result.name, 'Centro Sicuro');
      expect(result.latitude, 45.4);
      expect(result.category, 'Supporto');
    });

    /// Verifica che il metodo toJson converta correttamente
    /// un'istanza di [SafePlace] in una mappa JSON.
    test('toJson converte correttamente un SafePlace in JSON', () {
      final result = SafePlaceDTO.toJson(mockPlace);

      expect(result['marker_id'], '1');
      expect(result['name'], 'Centro Sicuro');
      expect(result['latitude'], 45.4);
    });
  });
}