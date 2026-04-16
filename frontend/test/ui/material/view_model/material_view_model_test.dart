import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/view_model/material_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/resource_type.dart';
import '../../../../testing/mocks/mock_material_repository.dart';

void main() {
  late MaterialViewModel viewModel;
  late MockMaterialRepository mockRepository;

  setUp(() {
    mockRepository = MockMaterialRepository();
    viewModel = MaterialViewModel(mockRepository);
  });

  group('MaterialViewModel Unit Test', () {
    test('loadMaterials deve popolare la lista dei materiali', () async {
      // Act
      await viewModel.loadMaterials.execute();

      // Assert
      expect(viewModel.materials.length, 3);
      expect(viewModel.currentFilter, isNull);
    });

    test('filterByType deve filtrare correttamente i materiali', () async {
      // Arrangia: carichiamo i dati
      await viewModel.loadMaterials.execute();

      // Act: applichiamo filtro LAW
      viewModel.filterByType(ResourceType.law);

      // Assert
      expect(viewModel.currentFilter, ResourceType.law);
      expect(viewModel.materials.length, 1);
      expect(viewModel.materials.every((r) => r.type == ResourceType.law), isTrue);
    });

    test('filterByType deve funzionare come un toggle', () async {
      await viewModel.loadMaterials.execute();

      // Seleziona LAW
      viewModel.filterByType(ResourceType.law);
      expect(viewModel.currentFilter, ResourceType.law);

      // Seleziona di nuovo LAW -> deve diventare null
      viewModel.filterByType(ResourceType.law);
      expect(viewModel.currentFilter, isNull);
      expect(viewModel.materials.length, 3);
    });

    test('Cambiare filtro deve aggiornare correttamente la vista filtrata', () async {
      await viewModel.loadMaterials.execute();

      viewModel.filterByType(ResourceType.law);
      expect(viewModel.materials[0].title, contains('Law'));

      viewModel.filterByType(ResourceType.community);
      expect(viewModel.materials[0].title, contains('Community'));
    });
  });
}
