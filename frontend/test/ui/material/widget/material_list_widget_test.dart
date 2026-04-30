import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/material/widget/material_list_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource_type.dart';

import '../../../../testing/mocks/material/mock_material_view_model.dart';
import '../../../../testing/mocks/core/mock_url_launcher_platform.dart';

// 1. Creiamo un Fake per LaunchOptions per soddisfare Mocktail
class FakeLaunchOptions extends Fake implements LaunchOptions {}

void main() {
  late MockMaterialViewModel mockVm;
  late MockUrlLauncherPlatform mockUrlLauncher;

  // 2. Registriamo il Fake nel setUpAll
  setUpAll(() {
    registerFallbackValue(FakeLaunchOptions());
  });

  setUp(() {
    mockVm = MockMaterialViewModel();

    // Mock di UrlLauncher per intercettare i click sui bottoni web
    mockUrlLauncher = MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockUrlLauncher;

    // Configura il mock di url_launcher per autorizzare l'apertura dei link.
    // Ora any() per LaunchOptions funzionerà grazie al Fake!
    when(() => mockUrlLauncher.canLaunch(any())).thenAnswer((_) async => true);
    when(() => mockUrlLauncher.launchUrl(any(), any())).thenAnswer((_) async => true);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: MaterialListWidget(viewModel: mockVm),
      ),
    );
  }

  group('MaterialListWidget - Render Tests', () {
    testWidgets('renderizza una lista vuota senza errori', (tester) async {
      when(() => mockVm.materials).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());

      // ListView dovrebbe essere presente ma senza ExpansionTile
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ExpansionTile), findsNothing);
    });

    testWidgets('renderizza correttamente le card delle risorse fornite', (tester) async {
      when(() => mockVm.materials).thenReturn([
        const Resource(
          id: '1',
          title: 'Titolo Articolo',
          type: ResourceType.article,
        ),
        const Resource(
          id: '2',
          title: 'Legge Test',
          type: ResourceType.law,
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ExpansionTile), findsNWidgets(2));
      expect(find.text('Titolo Articolo'), findsOneWidget);
      expect(find.text('Legge Test'), findsOneWidget);
    });
  });

  group('MaterialListWidget - Expansion & Interactions', () {
    testWidgets('espande la card e mostra il contenuto testuale', (tester) async {
      when(() => mockVm.materials).thenReturn([
        const Resource(
          id: 'test_exp',
          title: 'Titolo Espandibile',
          content: 'Testo di prova nascosto',
          type: ResourceType.community,
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());

      // Il contenuto inizialmente non è visibile
      expect(find.text('Testo di prova nascosto'), findsNothing);

      // Clicca sulla card (ExpansionTile) per espanderla
      await tester.tap(find.text('Titolo Espandibile'));

      // Aspettiamo che l'animazione di espansione si concluda
      await tester.pumpAndSettle();

      // Ora il contenuto deve essere visibile
      expect(find.text('Testo di prova nascosto'), findsOneWidget);

      // Dato che non c'è URL, il bottone non deve esserci
      expect(find.text('Visita il Link'), findsNothing);
    });

    testWidgets('mostra il bottone URL se presente e interagisce con url_launcher', (tester) async {
      const testUrl = 'https://example.com';
      when(() => mockVm.materials).thenReturn([
        const Resource(
          id: 'test_url',
          title: 'Risorsa con Link',
          url: testUrl,
          type: ResourceType.article,
        ),
      ]);

      await tester.pumpWidget(createWidgetUnderTest());

      // Espande la card
      await tester.tap(find.text('Risorsa con Link'));
      await tester.pumpAndSettle();

      // Verifica la presenza del bottone
      final buttonFinder = find.widgetWithText(FilledButton, 'Visita il Link');
      expect(buttonFinder, findsOneWidget);

      // Clicca il bottone
      await tester.tap(buttonFinder);
      await tester.pumpAndSettle();

      // Verifica che UrlLauncher sia stato invocato con l'URL corretto
      verify(() => mockUrlLauncher.canLaunch(testUrl)).called(1);
      verify(() => mockUrlLauncher.launchUrl(testUrl, any())).called(1);
    });

    testWidgets('mostra uno SnackBar di errore se url_launcher fallisce', (tester) async {
      const badUrl = 'https://badurl.com';
      when(() => mockVm.materials).thenReturn([
        const Resource(
          id: 'bad_url',
          title: 'Link Rotto',
          url: badUrl,
          type: ResourceType.article,
        ),
      ]);

      // Simuliamo il fallimento del check di canLaunch
      when(() => mockUrlLauncher.canLaunch(badUrl)).thenAnswer((_) async => false);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Link Rotto'));
      await tester.pumpAndSettle();

      // Clicca il bottone che ora dovrebbe fallire e sollevare l'eccezione
      await tester.tap(find.widgetWithText(FilledButton, 'Visita il Link'));
      await tester.pump(); // Esegui microtask (showSnackBar)
      await tester.pumpAndSettle(); // Finisci animazione SnackBar

      // Verifica che lo SnackBar di errore venga mostrato
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Ops! Impossibile aprire questo link.'), findsOneWidget);
    });
  });
}