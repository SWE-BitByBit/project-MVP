import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

// Sostituisci i percorsi con quelli del tuo progetto
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_send_message_widget.dart'; // Nome del file
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/message_response.dart';

// Importiamo la nostra controfigura
import '../../../../testing/mocks/chatbot/mock_chatbot_repository.dart';

void main() {
  group('ChatbotSendMessageWidget Widget Test', () {
    late MockChatbotRepository mockRepo;
    late ChatbotViewModel viewModel;

    setUp(() async {
      mockRepo = MockChatbotRepository();
      viewModel = ChatbotViewModel(mockRepo);

      // 1. Fondamentale: Apriamo/Creiamo una chat, altrimenti il ViewModel
      // rifiuterà il messaggio dicendo "Nessuna chat attiva"
      await viewModel.createChat();

      // 2. Prepariamo il mock in modo che non vada in errore quando riceve il messaggio
      mockRepo.mockedMessageResponse = MessageResponse(
        response: ChatMessage(
          id: 'ai-1',
          content: 'Ricevuto forte e chiaro',
          type: MessageType.AI,
          timestamp: DateTime.now(),
        ),
      );
    });

    Future<void> pumpInputWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChangeNotifierProvider<ChatbotViewModel>.value(
              value: viewModel,
              child: const ChatbotSendMessageWidget(),
            ),
          ),
        ),
      );
    }

    testWidgets('Deve mostrare il campo di testo e il bottone di invio', (WidgetTester tester) async {
      await pumpInputWidget(tester);

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.text('Scrivi qui...'), findsOneWidget); // Verifica l'hintText
    });

    testWidgets('Inserendo testo e premendo invio, pulisce il campo e aggiorna la chat', (WidgetTester tester) async {
      await pumpInputWidget(tester);

      // 1. Il robot inserisce il testo nel campo
      await tester.enterText(find.byType(TextField), 'Ciao AI, sono un test');

      // Verifichiamo che il testo sia effettivamente stato digitato
      expect(find.text('Ciao AI, sono un test'), findsOneWidget);

      // 2. Il robot preme l'icona "Invia"
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle(); // Aspettiamo che finisca la chiamata asincrona finta

      // 3. Verifichiamo che il campo di testo si sia svuotato
      expect(find.text('Ciao AI, sono un test'), findsNothing);

      // 4. Verifichiamo che il messaggio sia arrivato nel ViewModel
      final messages = viewModel.currentChat!.getMessages();
      expect(messages.length, 2, reason: 'Dovrebbero esserci il messaggio inviato e la risposta AI mockata');
      expect(messages.first.content, 'Ciao AI, sono un test');
    });

    testWidgets('L\'invio tramite tastiera (onSubmitted) funziona come il bottone', (WidgetTester tester) async {
      await pumpInputWidget(tester);

      // Inseriamo il testo
      await tester.enterText(find.byType(TextField), 'Test tastiera');

      // Simuliamo la pressione del tasto "Invio/Fine" sulla tastiera del telefono
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Verifichiamo che abbia pulito il campo (quindi ha fatto l'invio)
      expect(find.text('Test tastiera'), findsNothing);
      expect(viewModel.currentChat!.getMessages().first.content, 'Test tastiera');
    });

    testWidgets('Se il campo è vuoto o fatto solo di spazi, premere invio non fa nulla', (WidgetTester tester) async {
      await pumpInputWidget(tester);

      // Test vuoto puro
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Test con spazi
      await tester.enterText(find.byType(TextField), '    ');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Verifichiamo che la chat sia rimasta intonsa
      expect(viewModel.currentChat!.getMessages(), isEmpty);
    });
  });
}