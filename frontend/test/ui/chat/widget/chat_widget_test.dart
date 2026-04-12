import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Sostituisci i percorsi con quelli del tuo progetto
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chat_widget.dart'; // Nome del tuo file
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/message_response.dart';

// Importiamo la nostra controfigura
import '../../../../testing/mocks/mock_chatbot_repository.dart';

void main() {
  group('ChatWidget Widget Test', () {
    late MockChatbotRepository mockRepo;
    late ChatbotViewModel viewModel;

    setUp(() {
      mockRepo = MockChatbotRepository();
      viewModel = ChatbotViewModel(mockRepo);
    });

    /// Helper per montare il Widget
    Future<void> pumpChatWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ChatbotViewModel>.value(
              value: viewModel,
              child: const ChatWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets('Stato Iniziale: Deve mostrare il messaggio di benvenuto se la chat è vuota', (WidgetTester tester) async {
      // 1. Montiamo il widget senza aver creato nessuna chat (messages sarà vuoto)
      await pumpChatWidget(tester);

      // 2. Verifichiamo che appaia il testo di fallback
      expect(find.text('Inizia una conversazione sicura.'), findsOneWidget);
      // Assicuriamoci che non ci siano indicatori di caricamento
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Popolato: Deve mostrare i messaggi con l\'allineamento corretto', (WidgetTester tester) async {
      // 1. ARRANGE: Prepariamo i dati
      // Creiamo la chat
      await viewModel.createChat();

      // Prepariamo il mock per rispondere al nostro imminente messaggio
      final aiMessage = ChatMessage(
        id: 'msg-ai',
        content: 'Sono il detective AI, come posso aiutarti?',
        type: MessageType.AI,
        timestamp: DateTime.now(),
      );
      mockRepo.mockedMessageResponse = MessageResponse(response: aiMessage);

      // Inviamo il messaggio dell'utente (che scatenerà anche la risposta mockata dell'AI)
      await viewModel.sendChatMessage('Ciao, ho bisogno di aiuto');

      // 2. ACT: Montiamo l'interfaccia con i dati pronti
      await pumpChatWidget(tester);
      await tester.pumpAndSettle(); // Aspettiamo che la UI si stabilizzi

      // 3. ASSERT: Verifiche testuali
      expect(find.text('Ciao, ho bisogno di aiuto'), findsOneWidget);
      expect(find.text('Sono il detective AI, come posso aiutarti?'), findsOneWidget);

      // 4. ASSERT: Verifiche di Layout (Il livello "Pro" dei Widget Test)
      // Troviamo tutti i widget Align usati nel costruttore della ListView
      final alignWidgets = tester.widgetList<Align>(find.byType(Align));

      // Essendo la lista reverse: true, il primo elemento nell'albero (index 0)
      // sarà l'ultimo messaggio inviato, ovvero quello dell'AI.
      // Il secondo elemento (index 1) sarà quello dell'utente.

      final alignAi = alignWidgets.elementAt(0);
      final alignUser = alignWidgets.elementAt(1);

      // Verifichiamo gli allineamenti
      expect(alignAi.alignment, Alignment.centerLeft, reason: 'Il messaggio AI deve essere a sinistra');
      expect(alignUser.alignment, Alignment.centerRight, reason: 'Il messaggio Utente deve essere a destra');
    });
  });
}