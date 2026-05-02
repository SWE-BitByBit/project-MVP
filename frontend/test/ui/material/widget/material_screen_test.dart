import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:command_it/command_it.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/material/widget/material_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/view_model/material_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/material/widget/material_list_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource_type.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/material/resource.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_indicator.dart';

import '../../../../testing/mocks/material/mock_material_view_model.dart';

class MockCommandLoadMaterials extends Mock implements Command<void, void> {}
class MockCommandError extends Mock implements CommandError<void> {}

void main() {
  late MockMaterialViewModel mockVm;
  late MockCommandLoadMaterials mockLoadCommand;

  setUpAll(() {
    registerFallbackValue(ResourceType.article);
  });

  setUp(() {
    mockVm = MockMaterialViewModel();
    mockLoadCommand = MockCommandLoadMaterials();

    when(() => mockLoadCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockLoadCommand.errors).thenReturn(ValueNotifier<CommandError<void>?>(null));
    when(() => mockLoadCommand.run()).thenReturn(null);

    when(() => mockVm.loadMaterials).thenReturn(mockLoadCommand);
    when(() => mockVm.materials).thenReturn([]);
    when(() => mockVm.currentFilter).thenReturn(null);
    when(() => mockVm.filterByType(any())).thenReturn(null);
    when(() => mockVm.refreshMaterials()).thenAnswer((_) async {});

    // Registrazione sicura per GetIt.
    final sl = GetIt.instance;
    if (sl.isRegistered<MaterialViewModel>()) {
      sl.unregister<MaterialViewModel>();
    }
    sl.registerSingleton<MaterialViewModel>(mockVm);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        // Avvolgiamo in un provider .value() a monte per assicurarci che,
        // se il widget figlio legge dal context, trovi un'istanza valida viva.
        body: ChangeNotifierProvider<MaterialViewModel>.value(
          value: mockVm,
          child: const MaterialScreen(),
        ),
      ),
    );
  }

  group('MaterialScreen - UI Layout', () {
    testWidgets('renderizza la AppBar con il titolo corretto', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Materiale Informativo'), findsOneWidget);
    });

    testWidgets('renderizza i filtri per ogni ResourceType', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      for (final type in ResourceType.values) {
        expect(find.text(type.displayName), findsOneWidget);
      }
    });
  });

  group('MaterialScreen - States', () {
    testWidgets('mostra CircularProgressIndicator quando in caricamento e la cache è vuota', (tester) async {
      when(() => mockLoadCommand.isRunning).thenReturn(ValueNotifier<bool>(true));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('mostra ErrorIndicator in caso di errore di caricamento a cache vuota', (tester) async {
      final mockError = MockCommandError();
      when(() => mockLoadCommand.errors).thenReturn(ValueNotifier<CommandError<void>?>(mockError));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ErrorIndicator), findsOneWidget);

      await tester.tap(find.text('Riprova a scaricare'));
      verify(() => mockLoadCommand.run()).called(1);
    });

    testWidgets('mostra il messaggio se la lista è vuota', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Nessun materiale trovato.'), findsOneWidget);
    });

    testWidgets('mostra MaterialListWidget quando i dati sono presenti', (tester) async {
      when(() => mockVm.materials).thenReturn([
        const Resource(id: '1', title: 'Test', type: ResourceType.article)
      ]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(MaterialListWidget), findsOneWidget);
    });
  });

  group('MaterialScreen - Interactions', () {
    testWidgets('chiama filterByType quando si tappa su un filtro', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final filterText = ResourceType.values.first.displayName;
      await tester.tap(find.text(filterText));

      verify(() => mockVm.filterByType(ResourceType.values.first)).called(1);
    });

    testWidgets('eseguire il Pull-to-Refresh chiama refreshMaterials', (tester) async {
      when(() => mockVm.materials).thenReturn([
        const Resource(id: '1', title: 'Test', type: ResourceType.article)
      ]);
      await tester.pumpWidget(createWidgetUnderTest());

      // Assicuriamoci di agganciare il fling al MaterialListWidget
      await tester.fling(find.byType(MaterialListWidget), const Offset(0, 300), 1000);
      await tester.pumpAndSettle();

      verify(() => mockVm.refreshMaterials()).called(1);
    });
  });
}