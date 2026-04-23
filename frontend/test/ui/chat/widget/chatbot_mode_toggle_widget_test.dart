import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Sostituisci i percorsi in base al tuo progetto
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_mode_toggle_widget.dart'; // Nome del file
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';

// Importiamo la nostra controfigura
import '../../../../testing/mocks/chatbot/mock_chatbot_repository.dart';

void main() {
  group('ChatbotModeToggleWidget Widget Test', () {
    late MockChatbotRepository mockRepo;
    late ChatbotViewModel viewModel;

    setUp(() {
      mockRepo = MockChatbotRepository();
      viewModel = ChatbotViewModel(mockRepo);
    });

    Future<void> pumpToggleWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ChatbotViewModel>.value(
              value: viewModel,
              child: const ChatbotModeToggleWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets('Stato Iniziale: Deve mostrare la modalità DETECTIVE di default con la sua icona', (WidgetTester tester) async {
      await pumpToggleWidget(tester);

      // Verifichiamo che il ViewModel parta effettivamente come DETECTIVE
      expect(viewModel.selectedMode, ChatMode.DETECTIVE);

      // Verifichiamo che l'icona della psicologia (Detective) sia presente
      expect(find.byIcon(Icons.psychology), findsOneWidget);
      // Verifichiamo che l'altra icona NON ci sia
      expect(find.byIcon(Icons.auto_awesome_motion), findsNothing);

      // Verifichiamo che lo Switch sia su "ON" (true)
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isTrue);
    });

    testWidgets('Tappando lo Switch, cambia in modalità MIRROR e aggiorna l\'icona', (WidgetTester tester) async {
      await pumpToggleWidget(tester);

      // Troviamo lo switch e ci clicchiamo sopra per spegnerlo
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle(); // Aspettiamo che l'animazione dell'interruttore finisca

      // VERIFICA LOGICA: Il ViewModel ha registrato il cambio?
      expect(viewModel.selectedMode, ChatMode.MIRROR);

      // VERIFICA VISIVA: Le icone si sono scambiate?
      expect(find.byIcon(Icons.auto_awesome_motion), findsOneWidget); // Appare Mirror
      expect(find.byIcon(Icons.psychology), findsNothing); // Scompare Detective

      // Verifichiamo che lo Switch ora sia "OFF" (false)
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, isFalse);
    });

    testWidgets('Tappando due volte torna alla modalità DETECTIVE', (WidgetTester tester) async {
      await pumpToggleWidget(tester);

      // Doppio tap (Spegne e Riaccende)
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      // Verifica che sia tornato allo stato originario
      expect(viewModel.selectedMode, ChatMode.DETECTIVE);
      expect(find.byIcon(Icons.psychology), findsOneWidget);
    });
  });
}