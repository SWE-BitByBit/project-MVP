import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/material_repository.dart';
import '../../../testing/mocks/mock_material_service.dart';

void main() {
  late MaterialRepository repository;
  late MockMaterialService mockService;

  setUp(() {
    mockService = MockMaterialService();
    repository = MaterialRepository(mockService);
  });

  group('MaterialRepository Unit Test', () {
    test('getMaterials deve chiamare il servizio al primo tentativo', () async {
      // Act
      final materials = await repository.getMaterials();

      // Assert
      expect(materials.length, 2);
      expect(materials[0].title, 'Test Law');
    });

    test('getMaterials deve usare la cache interna per le chiamate successive', () async {
      // Prime caricamento
      await repository.getMaterials();
      
      // Modifichiamo il mock (se chiamasse il servizio, cambierebbero i dati)
      mockService.mockedData = [];

      // Act
      final cachedMaterials = await repository.getMaterials();

      // Assert
      expect(cachedMaterials.length, 2); // Ancora 2, presi dalla cache
      expect(cachedMaterials[0].title, 'Test Law');
    });
  });
}
