import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/safe_place_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place_enums.dart';

void main() {
  Map<String, dynamic> readFixture(String name) {
    final path = Directory.current.path.endsWith('test')
        ? '../testing/fixtures/safeplace/$name'
        : 'testing/fixtures/safeplace/$name';
    final file = File(path);
    return jsonDecode(file.readAsStringSync());
  }

  group('SafePlaceDTO Tests', () {
    group('fromJson', () {
      test('dovrebbe parsare correttamente un JSON valido (Happy Path)', () {
        // Arrange
        final json = readFixture('safe_place_valid.json');

        // Act
        final result = SafePlaceDTO.fromJson(json);

        // Assert
        expect(result, isA<SafePlace>());
        expect(result.id, 'sp_123');
        expect(result.name, 'Ospedale Maggiore');
        expect(result.address, 'Via Roma 1, Milano');
        expect(result.latitude, 45.4642);
        expect(result.longitude, 9.1900);
        expect(result.category, SafePlaceCategory.hospital);
      });

      test('dovrebbe usare id se marker_id non è presente', () {
        // Arrange
        final json = {
          'id': 'sp_alt_456',
          'name': 'Caserma Carabinieri',
          'latitude': 45.0,
          'longitude': 9.0,
          'category': 'carabinieri'
        };

        // Act
        final result = SafePlaceDTO.fromJson(json);

        // Assert
        expect(result.id, 'sp_alt_456');
        expect(result.category, SafePlaceCategory.police);
      });

      test('dovrebbe gestire la conversione sicura di latitudine e longitudine numeriche (non stringhe)', () {
        // Arrange
        final json = {
          'id': 'sp_num',
          'latitude': 41.9028,
          'longitude': 12.4964,
        };

        // Act
        final result = SafePlaceDTO.fromJson(json);

        // Assert
        expect(result.latitude, 41.9028);
        expect(result.longitude, 12.4964);
      });

      test('dovrebbe fornire valori di default per campi mancanti o nulli', () {
        // Arrange
        final json = readFixture('safe_place_incomplete.json');

        // Act
        final result = SafePlaceDTO.fromJson(json);

        // Assert
        expect(result.id, 'unknown');
        expect(result.name, 'Luogo senza nome');
        expect(result.address, 'Indirizzo non disponibile');
        expect(result.latitude, 0.0);
        expect(result.longitude, 0.0);
        expect(result.category, SafePlaceCategory.other);
      });

      test('dovrebbe gestire stringhe non numeriche per coordinate facendone il fallback a 0.0', () {
        // Arrange
        final json = {
          'latitude': 'invalid_lat',
          'longitude': 'invalid_lng',
        };

        // Act
        final result = SafePlaceDTO.fromJson(json);

        // Assert
        expect(result.latitude, 0.0);
        expect(result.longitude, 0.0);
      });

      test('dovrebbe mappare correttamente tutte le varianti di categoria', () {
        expect(SafePlaceDTO.fromJson({'category': 'pronto soccorso'}).category, SafePlaceCategory.hospital);
        expect(SafePlaceDTO.fromJson({'category': 'polizia'}).category, SafePlaceCategory.police);
        expect(SafePlaceDTO.fromJson({'category': 'questura'}).category, SafePlaceCategory.police);
        expect(SafePlaceDTO.fromJson({'category': 'farmacia'}).category, SafePlaceCategory.pharmacy);
        expect(SafePlaceDTO.fromJson({'category': 'centro_antiviolenza'}).category, SafePlaceCategory.emergencyShelter);
        expect(SafePlaceDTO.fromJson({'category': 'rifugio'}).category, SafePlaceCategory.emergencyShelter);
        expect(SafePlaceDTO.fromJson({'category': 'sconosciuta'}).category, SafePlaceCategory.other);
      });
    });

    group('toJson', () {
      test('dovrebbe serializzare correttamente un oggetto SafePlace in JSON', () {
        // Arrange
        final place = SafePlace(
          id: 'sp_789',
          name: 'Farmacia Centrale',
          address: 'Piazza Garibaldi 2',
          latitude: 44.4949,
          longitude: 11.3426,
          category: SafePlaceCategory.pharmacy,
        );

        // Act
        final result = SafePlaceDTO.toJson(place);

        // Assert
        expect(result['marker_id'], 'sp_789');
        expect(result['name'], 'Farmacia Centrale');
        expect(result['address'], 'Piazza Garibaldi 2');
        expect(result['latitude'], '44.4949'); // Deve essere stringa come da implementazione
        expect(result['longitude'], '11.3426'); // Deve essere stringa come da implementazione
        expect(result['category'], SafePlaceCategory.pharmacy.name);
      });
    });
  });
}
