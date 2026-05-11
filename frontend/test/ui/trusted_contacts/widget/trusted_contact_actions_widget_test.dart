import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:command_it/command_it.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_actions_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contact_form_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';

// --- MOCKS ---
class MockTrustedContactViewModel extends Mock
    implements TrustedContactViewModel {}

class MockCommandCreate extends Mock implements Command<TrustedContact, void> {}

void main() {
  late MockTrustedContactViewModel mockVm;
  late MockCommandCreate mockCreateCommand;

  setUp(() {
    mockVm = MockTrustedContactViewModel();
    mockCreateCommand = MockCommandCreate();

    // Configuriamo le dipendenze minime per far sopravvivere il TrustedContactFormWidget
    // che viene renderizzato all'interno del BottomSheet
    when(
      () => mockCreateCommand.isRunning,
    ).thenReturn(ValueNotifier<bool>(false));
    when(
      () => mockCreateCommand.errors,
    ).thenReturn(ValueNotifier<CommandError<TrustedContact>?>(null));

    // Colleghiamo il comando al ViewModel
    when(() => mockVm.createContact).thenReturn(mockCreateCommand);
    when(() => mockVm.errors).thenReturn(<String, String>{});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<TrustedContactViewModel>.value(
          value: mockVm,
          child: const TrustedContactActionsWidget(),
        ),
      ),
    );
  }

  group('TrustedContactActionsWidget - Layout & Interazioni', () {
    testWidgets('renderizza il FloatingActionButton con l\'icona + (add)', (
      tester,
    ) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verifica la corretta renderizzazione del pulsante
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets(
      'al tocco apre il BottomSheet contenente TrustedContactFormWidget',
      (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Prima del tap, la modale non deve esserci
        expect(find.byType(TrustedContactFormWidget), findsNothing);

        // Eseguiamo il tap sul FAB
        await tester.tap(find.byType(FloatingActionButton));

        // Aspettiamo che l'animazione di entrata del BottomSheet sia completata.
        await tester.pumpAndSettle();

        // Verifichiamo che la modale si sia aperta mostrando il form
        expect(find.byType(TrustedContactFormWidget), findsOneWidget);
      },
    );
  });
}
