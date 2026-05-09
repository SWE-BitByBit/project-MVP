
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:mvp_app_protegge_e_trasforma/main.dart' as app;
import 'package:mvp_app_protegge_e_trasforma/utils/locator.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/material_service.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/filter_chip_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/material_repository.dart';

class MockMaterialService extends Mock implements MaterialService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockMaterialService mockMaterialService;

  setUp(() {
    mockMaterialService = MockMaterialService();

    getIt.allowReassignment = true;
    getIt.registerLazySingleton<MaterialService>(() => mockMaterialService);

    final mockResourcesJson = {
      'data': [
        {
          "resource_id": "1",
          "title": "Come proteggersi online",
          "content": "Guida base sulla sicurezza",
          "url": "https://example.com/guide/1",
          "type": "article"
        },
        {
          "resource_id": "2",
          "title": "Legge Codice Rosso",
          "content": "Dettagli sulla normativa",
          "url": "https://example.com/law",
          "type": "law"
        },
        {
          "resource_id": "3",
          "title": "Supporto Psicologico Comunitario",
          "content": "Risorse locali",
          "url": "https://example.com/community",
          "type": "community"
        }
      ]
    };

    when(() => mockMaterialService.fetchMaterials()).thenAnswer((_) async => mockResourcesJson);
  });

  testWidgets('Test di integrazione End-to-End: Navigazione Materiale Informativo e Filtri', (WidgetTester tester) async {
    // 1. Inizializza l'ambiente e il locator reale
    try {
      await app.main();
    } catch (_) {}
    
    // SOVRASCRIVI i locator reali con i mock PRIMA di navigare
    getIt.allowReassignment = true;
    getIt.registerLazySingleton<MaterialService>(() => mockMaterialService);
    getIt.registerLazySingleton<MaterialRepository>(() => MaterialRepository(service: mockMaterialService));

    await tester.pumpAndSettle();

    // 2. Naviga alla schermata Materiale Informativo
    final materialCard = find.text('Informazioni');
    expect(materialCard, findsWidgets); // Può essere nell'AppBar e nella Home
    
    // Clicca sull'icona nella grid della Home
    await tester.tap(materialCard.last);
    await tester.pumpAndSettle();

    // 3. Verifica il caricamento della lista
    expect(find.text('Materiale Informativo'), findsWidgets); // Titolo AppBar
    
    // Verifica che le risorse mockate siano renderizzate
    expect(find.text('Come proteggersi online'), findsOneWidget);
    expect(find.text('Legge Codice Rosso'), findsOneWidget);

    // 4. Utilizzo dei filtri
    // Troviamo il chip "Normative" e lo clicchiamo
    final lawChip = find.widgetWithText(FilterChipWidget, 'Normative');
    expect(lawChip, findsOneWidget);
    
    await tester.tap(lawChip);
    await tester.pumpAndSettle();

    // Dopo aver filtrato per "Normative", l'articolo non dovrebbe essere visibile
    expect(find.text('Come proteggersi online'), findsNothing);
    expect(find.text('Legge Codice Rosso'), findsOneWidget);

    // Clicchiamo "Normative" di nuovo per deselezionarlo e ripristinare la lista
    await tester.tap(lawChip);
    await tester.pumpAndSettle();

    expect(find.text('Come proteggersi online'), findsOneWidget);

    verify(() => mockMaterialService.fetchMaterials()).called(1);
  });
}
