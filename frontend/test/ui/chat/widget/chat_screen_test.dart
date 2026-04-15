import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Sostituisci i percorsi in base al tuo progetto
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chat_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chat_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_send_message_widget.dart';

import '../../../../testing/mocks/mock_chatbot_repository.dart';

void main() {
  group('ChatScreen (Integration UI Test)', () {
    late MockChatbotRepository mockRepo;
    late ChatbotViewModel viewModel;

    setUp(() {
      mockRepo = MockChatbotRepository();
      viewModel = ChatbotViewModel(mockRepo);
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ChatbotViewModel>.value(
            value: viewModel,
            // ATTENZIONE: Testiamo la ChatScreenView, non il ChatScreen wrapper!
            child: const ChatScreenView(),
          ),
        ),
      );
    }

    testWidgets('Deve montare tutti i widget principali e mostrare il titolo di default', (WidgetTester tester) async {
      await pumpScreen(tester);

      // Verifichiamo che i pezzi del puzzle ci siano tutti
      expect(find.byType(ChatWidget), findsOneWidget);
      expect(find.byType(ChatbotSendMessageWidget), findsOneWidget);

      // Verifichiamo l'_AppBarTitle di default
      expect(find.text('Nuova Conversazione'), findsOneWidget);
    });

    testWidgets('Deve mostrare l\'indicatore di caricamento quando isLoading è true', (WidgetTester tester) async {
      await pumpScreen(tester);

      // 1. Diciamo al mock principale di "rallentare" solo per questo test!
      mockRepo.simulatedDelay = const Duration(seconds: 1);

      // 2. Facciamo partire l'azione (senza usare 'await', così non rimaniamo bloccati)
      viewModel.createChat();

      // 3. Facciamo avanzare Flutter di un singolo frame
      await tester.pump();

      // 4. Verifichiamo che la barra di caricamento sia apparsa
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // 5. Ripuliamo il tempo rimasto per concludere il test senza errori
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Opzionale: rimettiamo il tempo a zero per i test futuri (anche se il setUp lo resetta già)
      mockRepo.simulatedDelay = Duration.zero;
    });

    testWidgets('Deve mostrare il messaggio di errore rosso se il backend fallisce', (WidgetTester tester) async {
      await pumpScreen(tester);

      // Diciamo al mock di lanciare un'eccezione
      mockRepo.shouldThrowError = true;

      // Proviamo ad aprire una chat (che fallirà per colpa del mock)
      await viewModel.openChat('chat-1');
      await tester.pumpAndSettle();

      // Verifichiamo che il Consumer abbia disegnato il testo rosso dell'errore
      expect(find.textContaining('Errore nell\'apertura della chat'), findsOneWidget);
    });

    testWidgets('Tappare sullo schermo fuori dalla tastiera deve togliere il focus', (WidgetTester tester) async {
      await pumpScreen(tester);

      // 1. Troviamo il campo di testo e ci clicchiamo per aprire la "tastiera"
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // Verifica sicura: c'è un elemento attivo (la tastiera è aperta)?
      expect(FocusManager.instance.primaryFocus?.hasFocus, isTrue);

      // 2. Tocchiamo un punto "sicuro" che non ruba i tocchi (il testo dell'AppBar)
      await tester.tap(find.text('Nuova Conversazione'));
      await tester.pump();

      // 3. Se il tuo GestureDetector ha funzionato, il focus primario è stato rimosso
      // e l'app non è più focalizzata sul campo di testo!
      final isKeyboardOpen = FocusManager.instance.primaryFocus?.context?.widget is EditableText;
      expect(isKeyboardOpen, isFalse, reason: 'La tastiera dovrebbe essersi chiusa');
    });
  });
}