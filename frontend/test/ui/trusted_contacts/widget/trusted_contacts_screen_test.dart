import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:get_it/get_it.dart';
import 'package:command_it/command_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_list_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_actions_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_indicator.dart';

import '../../../../testing/mocks/trusted_contacts/mock_trusted_contact_view_model.dart';

class MockCommandErrorVoid extends Mock implements CommandError<void> {}
class MockCommandErrorString extends Mock implements CommandError<String> {}

void main() {
  late MockTrustedContactViewModel mockVm;
  late MockCommandLoad mockLoadCommand;
  late MockCommandDelete mockDeleteCommand;
  late MockCommandCreate mockCreateCommand;
  late MockCommandUpdate mockUpdateCommand;

  // Notifiers per il controllo reattivo
  late ValueNotifier<bool> loadRunningNotifier;
  late ValueNotifier<CommandError<void>?> loadErrorNotifier;
  late ValueNotifier<CommandError<String>?> deleteErrorNotifier;

  setUp(() async {
    final sl = GetIt.instance;
    await sl.reset();

    mockVm = MockTrustedContactViewModel();
    mockLoadCommand = MockCommandLoad();
    mockDeleteCommand = MockCommandDelete();
    mockCreateCommand = MockCommandCreate();
    mockUpdateCommand = MockCommandUpdate();

    loadRunningNotifier = ValueNotifier<bool>(false);
    loadErrorNotifier = ValueNotifier<CommandError<void>?>(null);
    deleteErrorNotifier = ValueNotifier<CommandError<String>?>(null);

    // Setup base stato UI
    when(() => mockVm.contacts).thenReturn([]);

    // 1. Setup Load (Usato dalla Screen)
    when(() => mockLoadCommand.isRunning).thenReturn(loadRunningNotifier);
    when(() => mockLoadCommand.errors).thenReturn(loadErrorNotifier);
    when(() => mockLoadCommand.run(any())).thenReturn(null);
    when(() => mockVm.loadContacts).thenReturn(mockLoadCommand);

    // 2. Setup Delete (Ascoltato nel initState della Screen)
    when(() => mockDeleteCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockDeleteCommand.errors).thenReturn(deleteErrorNotifier);
    when(() => mockVm.deleteContact).thenReturn(mockDeleteCommand);

    // 3. Setup Create & Update (Necessari per la sopravvivenza dei Widget figli)
    when(() => mockCreateCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockCreateCommand.errors).thenReturn(ValueNotifier<CommandError<TrustedContact>?>(null));
    when(() => mockVm.createContact).thenReturn(mockCreateCommand);

    when(() => mockUpdateCommand.isRunning).thenReturn(ValueNotifier<bool>(false));
    when(() => mockUpdateCommand.errors).thenReturn(ValueNotifier<CommandError<TrustedContact>?>(null));
    when(() => mockVm.updateContact).thenReturn(mockUpdateCommand);

    // Registrazione in GetIt
    sl.registerSingleton<TrustedContactViewModel>(mockVm);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      home: TrustedContactScreen(),
    );
  }

  group('TrustedContactScreen - Rendering', () {
    testWidgets('renderizza AppBar e FAB', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Contatti Fidati'), findsOneWidget);
      expect(find.byType(TrustedContactActionsWidget), findsOneWidget);
    });

    testWidgets('mostra CircularProgressIndicator in fase di caricamento', (tester) async {
      loadRunningNotifier.value = true;

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(TrustedContactListWidget), findsNothing);
      expect(find.byType(ErrorIndicator), findsNothing);
    });

    testWidgets('mostra ErrorIndicator in caso di errore di caricamento', (tester) async {
      loadErrorNotifier.value = MockCommandErrorVoid();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ErrorIndicator), findsOneWidget);
      expect(find.text('Errore nel caricamento'), findsOneWidget);

      // Simula tocco su "Prego riprovare"
      await tester.tap(find.text('Prego riprovare'));
      verify(() => mockLoadCommand.run(null)).called(1);
    });

    testWidgets('mostra TrustedContactListWidget se il caricamento ha successo', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(TrustedContactListWidget), findsOneWidget);
    });
  });

  group('TrustedContactScreen - Listener di Errore', () {
    testWidgets('mostra uno SnackBar se deleteContact spara un errore (rollback fail)', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Non c'è nessuno SnackBar all'inizio
      expect(find.byType(SnackBar), findsNothing);

      // Il ViewModel notifica un errore di cancellazione dal repository in background
      deleteErrorNotifier.value = MockCommandErrorString();
      await tester.pump(); // Esegue il callback del listener
      await tester.pumpAndSettle(); // Aspetta l'animazione della SnackBar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Impossibile eliminare il contatto: errore di rete.'), findsOneWidget);
    });
  });
}