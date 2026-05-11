import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/resource_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource_type.dart';

void main() {
  Map<String, dynamic> readFixture(String name) {
    final path = Directory.current.path.endsWith('test')
        ? '../testing/fixtures/material/$name'
        : 'testing/fixtures/material/$name';
    final file = File(path);
    return jsonDecode(file.readAsStringSync());
  }

  group('ResourceDTO Tests', () {
    group('fromJson', () {
      test('dovrebbe parsare correttamente un JSON completo e valido (Happy Path)', () {
        // Arrange
        final json = readFixture('resource_valid.json');

        // Act
        final result = ResourceDTO.fromJson(json);

        // Assert
        expect(result, isA<Resource>());
        expect(result.id, 'res_123');
        expect(result.title, 'Guida alla sicurezza personale');
        expect(result.content, 'Ecco alcune linee guida fondamentali per proteggere la propria privacy...');
        expect(result.url, 'https://example.com/guida-sicurezza.pdf');

        // Assumiamo che ResourceType.fromString('document') restituisca il valore corretto dell'enum
        // L'asserzione esatta dipenderà dall'implementazione interna di ResourceType
        expect(result.type, ResourceType.fromString('document'));
      });

      test('dovrebbe fornire valori di default per campi mancanti o nulli', () {
        // Arrange
        final json = readFixture('resource_incomplete.json');

        // Act
        final result = ResourceDTO.fromJson(json);

        // Assert
        expect(result.id, 'unknown');
        expect(result.title, 'Risorsa senza titolo');
        expect(result.content, isNull);
        expect(result.url, isNull);
        // Assumiamo che ResourceType.fromString(null) restituisca un default (es. unknown o simile)
        expect(result.type, ResourceType.fromString(null));
      });

      test('dovrebbe gestire resource_id numerico convertendolo in stringa', () {
        // Arrange
        final json = {
          'resource_id': 999,
          'title': 'Test ID',
        };

        // Act
        final result = ResourceDTO.fromJson(json);

        // Assert
        expect(result.id, '999');
        expect(result.title, 'Test ID');
      });
    });

    group('toJson', () {
      test('dovrebbe serializzare correttamente un oggetto Resource completo in JSON', () {
        // Arrange
        final resource = Resource(
          id: 'res_456',
          title: 'Video Tutorial',
          content: 'Descrizione del video',
          url: 'https://video.example.com',
          type: ResourceType.fromString('video'),
        );

        // Act
        final result = ResourceDTO.toJson(resource);

        // Assert
        expect(result['resource_id'], 'res_456');
        expect(result['title'], 'Video Tutorial');
        expect(result['content'], 'Descrizione del video');
        expect(result['url'], 'https://video.example.com');
        // La serializzazione usa il getter .name dell'enum
        expect(result['type'], resource.type.name);
      });

      test('dovrebbe serializzare correttamente una Resource con campi nulli', () {
        // Arrange
        final resource = Resource(
          id: 'res_minimal',
          title: 'Solo Titolo',
          content: null,
          url: null,
          type: ResourceType.fromString('unknown'),
        );

        // Act
        final result = ResourceDTO.toJson(resource);

        // Assert
        expect(result['resource_id'], 'res_minimal');
        expect(result['title'], 'Solo Titolo');
        expect(result['content'], isNull);
        expect(result['url'], isNull);
        expect(result['type'], resource.type.name);
      });
    });
  });
}