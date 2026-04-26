import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/resource_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource_type.dart';

void main() {
  group('ResourceDTO Unit Test', () {
    test('fromJson deve mappare correttamente tutti i campi con resource_id', () {
      final json = {
        'resource_id': 'res-123',
        'title': 'Test Title',
        'content': 'Test Content',
        'url': 'https://test.com',
        'type': 'law'
      };

      final resource = ResourceDTO.fromJson(json);

      expect(resource.id, 'res-123');
      expect(resource.title, 'Test Title');
      expect(resource.content, 'Test Content');
      expect(resource.url, 'https://test.com');
      expect(resource.type, ResourceType.law);
    });

    test('fromJson deve gestire i campi nulli con valori di default', () {
      final json = {
        'resource_id': null,
        'title': null,
        'type': null
      };

      final resource = ResourceDTO.fromJson(json);

      expect(resource.id, '');
      expect(resource.title, 'Senza Titolo');
      expect(resource.type, ResourceType.article);
    });

    test('fromJson deve fare il fallback a article se il tipo è sconosciuto', () {
      final json = {
        'resource_id': '1',
        'title': 'T',
        'type': 'unknown_type'
      };

      final resource = ResourceDTO.fromJson(json);

      expect(resource.type, ResourceType.article);
    });

    test('toJson deve produrre una mappa con chiave id interna', () {
      final json = {
        'resource_id': '1',
        'title': 'T',
        'content': 'C',
        'url': 'U',
        'type': 'community'
      };

      final resource = ResourceDTO.fromJson(json);
      final resultJson = ResourceDTO.toJson(resource);

      expect(resultJson['id'], '1');
      expect(resultJson['title'], 'T');
      expect(resultJson['type'], 'community');
    });

    test('fromJson deve riconoscere il tipo LAW in maiuscolo (formato Lambda)', () {
      final json = {
        'resource_id': 'legge-1',
        'title': 'Codice Rosso',
        'content': 'Testo della legge',
        'url': null,
        'type': 'LAW'
      };

      final resource = ResourceDTO.fromJson(json);

      expect(resource.id, 'legge-1');
      expect(resource.type, ResourceType.law);
      expect(resource.url, isNull);
    });

    test('fromJson deve riconoscere il tipo COMMUNITY in maiuscolo (formato Lambda)', () {
      final json = {
        'resource_id': 'comm-1',
        'title': 'Comunità',
        'content': null,
        'url': 'https://community.example.com',
        'type': 'COMMUNITY'
      };

      final resource = ResourceDTO.fromJson(json);

      expect(resource.type, ResourceType.community);
      expect(resource.content, isNull);
    });

    test('fromJson deve riconoscere il tipo ARTICLE in maiuscolo (formato Lambda)', () {
      final json = {
        'resource_id': 'art-1',
        'title': 'Articolo',
        'content': 'Testo',
        'url': null,
        'type': 'ARTICLE'
      };

      final resource = ResourceDTO.fromJson(json);

      expect(resource.type, ResourceType.article);
    });

    test('fromJson deve restituire id vuoto se resource_id è assente dalla mappa', () {
      final json = <String, dynamic>{
        'title': 'Senza ID',
        'type': 'LAW'
      };

      final resource = ResourceDTO.fromJson(json);

      expect(resource.id, '');
    });
  });
}
