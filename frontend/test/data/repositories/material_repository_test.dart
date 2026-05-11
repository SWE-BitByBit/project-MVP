import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/material_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource_type.dart';

import '../../../testing/mocks/material/mock_material_service.dart';

void main() {
  late MockMaterialService mockService;
  late MaterialRepository repository;

  setUp(() {
    mockService = MockMaterialService();
    repository = MaterialRepository(service: mockService);
  });

  group('MaterialRepository Tests', () {
    final mockApiResponse = {
      'data': [
        {
          'resource_id': 'res_1',
          'title': 'Guida 1',
          'type': 'document',
          'url': 'https://test.com/1'
        },
        {
          'resource_id': 'res_2',
          'title': 'Video 2',
          'type': 'video',
          'url': 'https://test.com/2'
        }
      ]
    };

    test('cachedResources dovrebbe essere inizialmente vuoto', () {
      expect(repository.cachedResources, isEmpty);
    });

    group('fetchMaterials', () {
      test('dovrebbe scaricare dati dal service, popolare la cache e restituire la lista (Happy Path)', () async {
        // Arrange
        when(() => mockService.fetchMaterials()).thenAnswer((_) async => mockApiResponse);

        // Act
        final results = await repository.fetchMaterials();

        // Assert
        expect(results.length, 2);
        expect(results[0].id, 'res_1');
        expect(results[1].title, 'Video 2');
        expect(repository.cachedResources.length, 2);
        verify(() => mockService.fetchMaterials()).called(1);
      });

      test('dovrebbe restituire i dati dalla cache senza chiamare il service se non è vuota', () async {
        // Arrange
        when(() => mockService.fetchMaterials()).thenAnswer((_) async => mockApiResponse);
        await repository.fetchMaterials(); // Prima chiamata (popola cache)
        clearInteractions(mockService);

        // Act
        final results = await repository.fetchMaterials(); // Seconda chiamata

        // Assert
        expect(results.length, 2);
        verifyNever(() => mockService.fetchMaterials());
      });

      test('dovrebbe forzare il refresh se forceRefresh è true', () async {
        // Arrange
        when(() => mockService.fetchMaterials()).thenAnswer((_) async => mockApiResponse);
        await repository.fetchMaterials(); // Popola cache iniziale

        // FIX: Resettiamo le interazioni per verificare solo la chiamata di refresh
        clearInteractions(mockService);

        final updatedResponse = {
          'data': [
            {'resource_id': 'res_new', 'title': 'Nuova Risorsa', 'type': 'document'}
          ]
        };
        when(() => mockService.fetchMaterials()).thenAnswer((_) async => updatedResponse);

        // Act
        final results = await repository.fetchMaterials(forceRefresh: true);

        // Assert
        expect(results.length, 1);
        expect(results.first.id, 'res_new');
        verify(() => mockService.fetchMaterials()).called(1);
      });
    });

    group('clearCache', () {
      test('dovrebbe svuotare la lista cachedResources', () async {
        // Arrange
        when(() => mockService.fetchMaterials()).thenAnswer((_) async => mockApiResponse);
        await repository.fetchMaterials();
        expect(repository.cachedResources.isNotEmpty, isTrue);

        // Act
        repository.clearCache();

        // Assert
        expect(repository.cachedResources, isEmpty);
      });
    });

    test('cachedResources (UnmodifiableListView) dovrebbe lanciare errore se si prova a modificarlo direttamente', () async {
      // Arrange
      when(() => mockService.fetchMaterials()).thenAnswer((_) async => mockApiResponse);
      await repository.fetchMaterials();

      // Act & Assert
      expect(() => (repository.cachedResources as dynamic).add(
          Resource(
              id: '3',
              title: 'Fake',
              type: ResourceType.fromString('unknown')
          )
      ), throwsUnsupportedError);
    });
  });
}