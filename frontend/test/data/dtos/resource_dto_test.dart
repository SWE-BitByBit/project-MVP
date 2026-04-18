import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/resource_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource_type.dart';

void main() {
  group('ResourceDTO Unit Test', () {
    test('fromJson deve mappare correttamente tutti i campi', () {
      final json = {
        'id': 'res-123',
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

    test('fromJson deve gestire i campi mancanti con valori di default', () {
      final json = {
        'id': null,
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
        'id': '1',
        'title': 'T',
        'type': 'unknown_type'
      };

      final resource = ResourceDTO.fromJson(json);

      expect(resource.type, ResourceType.article);
    });

    test('toJson deve produrre una mappa corretta', () {
      final json = {
        'id': '1',
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
  });
}
