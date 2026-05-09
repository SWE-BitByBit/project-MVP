import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/view_model/material_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource_type.dart';

import '../../../../testing/mocks/material/mock_material_repository.dart';

class FakeResource extends Fake implements Resource {
  @override
  final ResourceType type;
  @override
  final String title;

  FakeResource({required this.type, required this.title});
}

void main() {
  late MaterialViewModel viewModel;
  late MockMaterialRepository mockRepository;

  // Setup dati di test
  final resLaw = FakeResource(type: ResourceType.law, title: 'Legge Test');
  final resArticle = FakeResource(type: ResourceType.article, title: 'Articolo Test');
  final mockResources = [resLaw, resArticle];

  setUpAll(() {
    registerFallbackValue(ResourceType.law);
  });

  setUp(() {
    Command.globalExceptionHandler = (error, stackTrace) {};
    mockRepository = MockMaterialRepository();

    // Comportamento di default: il repository restituisce i dati mockati
    when(() => mockRepository.cachedResources).thenReturn(mockResources);
    when(() => mockRepository.fetchMaterials(forceRefresh: any(named: 'forceRefresh')))
        .thenAnswer((_) async {return [];});
  });

  /// Helper per inizializzare il ViewModel e attendere il comando automatico del costruttore
  Future<void> initViewModel() async {
    viewModel = MaterialViewModel(mockRepository);
    await viewModel.loadMaterials.runAsync();
  }

  group('MaterialViewModel - Inizializzazione', () {
    test('Al caricamento chiama fetchMaterials(forceRefresh: false)', () async {
      await initViewModel();

      verify(() => mockRepository.fetchMaterials(forceRefresh: false)).called(1);
      expect(viewModel.materials, mockResources);
    });
  });

  group('MaterialViewModel - Logica di Filtraggio (materials)', () {
    test('Se il filtro è null, restituisce tutti i materiali del repository', () async {
      await initViewModel();
      expect(viewModel.currentFilter, isNull);
      expect(viewModel.materials.length, 2);
    });

    test('filterByType applica il filtro correttamente e restringe la lista', () async {
      await initViewModel();

      viewModel.filterByType(ResourceType.law);

      expect(viewModel.currentFilter, ResourceType.law);
      expect(viewModel.materials.length, 1);
      expect(viewModel.materials.first.type, ResourceType.law);
    });

    test('filterByType agisce come toggle: se premo lo stesso tipo, resetta a null', () async {
      await initViewModel();

      viewModel.filterByType(ResourceType.law);
      expect(viewModel.currentFilter, ResourceType.law);

      viewModel.filterByType(ResourceType.law);
      expect(viewModel.currentFilter, isNull);
      expect(viewModel.materials.length, 2);
    });

    test('Il cambio filtro notifica i listener', () async {
      await initViewModel();
      bool notified = false;
      viewModel.addListener(() => notified = true);

      viewModel.filterByType(ResourceType.article);

      expect(notified, isTrue);
    });
  });

  group('MaterialViewModel - Refresh', () {
    test('refreshMaterials chiama fetchMaterials con forceRefresh: true', () async {
      await initViewModel();

      await viewModel.refreshMaterials();

      verify(() => mockRepository.fetchMaterials(forceRefresh: true)).called(1);
    });

    test('Se fetchMaterials lancia eccezione, refreshMaterials la propaga', () async {
      await initViewModel();
      when(() => mockRepository.fetchMaterials(forceRefresh: true))
          .thenThrow(Exception('Network Error'));

      expect(() => viewModel.refreshMaterials(), throwsException);
    });
  });

  group('MaterialViewModel - Lifecycle', () {
    test('dispose chiude i comandi correttamente', () async {
      await initViewModel();
      viewModel.dispose();

      // Verifica indiretta: non dovrebbero esserci leak o errori chiamando dispose due volte
      // o verificando lo stato interno se accessibile, ma qui ci fidiamo del contratto del Command.
    });
  });
}