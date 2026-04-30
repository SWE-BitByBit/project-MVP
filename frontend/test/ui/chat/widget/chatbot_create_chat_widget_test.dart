import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_create_chat_widget.dart'; // Adatta il nome del file se diverso
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import '../../../../testing/mocks/mock_chatbot_repository.dart';

void main() {
  group('ChatbotCreateChatWidget Widget Test', () {
    late MockChatbotRepository mockRepo;
    late ChatbotViewModel viewModel;

    setUp(() {
      // Inizializziamo il ViewModel "vero" ma collegato a internet "finto" (il Mock)
      mockRepo = MockChatbotRepository();
      viewModel = ChatbotViewModel(mockRepo);
    });

    testWidgets('Deve mostrare l\'icona e creare una nuova chat al click', (WidgetTester tester) async {

      // 1. ARRANGE: Montiamo l'interfaccia con il Provider
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // Il ChangeNotifierProvider.value è perfetto per i test perché
            // ci permette di iniettare un'istanza che abbiamo già creato noi nel setUp
            body: ChangeNotifierProvider<ChatbotViewModel>.value(
              value: viewModel,
              child: const ChatbotCreateChatWidget(),
            ),
          ),
        ),
      );

      // 2. ASSERT (Test Visivo): Verifichiamo che l'icona sia corretta
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.add_comment_outlined), findsOneWidget);

      // Sanity check: all'inizio non ci deve essere nessuna chat attiva
      expect(viewModel.currentChat, isNull);

      // 3. ACT: Tappiamo il bottone
      await tester.tap(find.byType(IconButton));

      // pumpAndSettle dice al robot di aspettare che finiscano tutte le animazioni
      // e che i Future (come la chiamata al mock repo) siano completati.
      await tester.pumpAndSettle();

      // 4. ASSERT (Test Logico): Verifichiamo che il click abbia avuto effetto sul ViewModel
      expect(viewModel.currentChat, isNotNull, reason: 'Il ViewModel dovrebbe avere una chat attiva ora');
      expect(viewModel.currentChat!.getId(), 'chat-test-123', reason: 'Dovrebbe essere la chat generata dal Mock');
    });

  });
}
