import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chat_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';

import '../../../../testing/mocks/chatbot/mock_chat.dart';
import '../../../../testing/mocks/chatbot/mock_chatbot_view_model.dart';



void main() {
  late MockChatbotViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockChatbotViewModel();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<ChatbotViewModel>.value(
          value: mockViewModel,
          child: const ChatWidget(),
        ),
      ),
    );
  }

  group('ChatWidget', () {
    testWidgets('Mostra messaggio placeholder se non c\'è una chat corrente o è vuota', (tester) async {
      when(() => mockViewModel.currentChat).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Inizia una conversazione sicura.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('Mostra la lista dei messaggi se la chat contiene messaggi', (tester) async {
      final mockChat = MockChat();
      final mockMsg1 = MockChatMessage();
      final mockMsg2 = MockChatMessage();

      when(() => mockMsg1.content).thenReturn('Ciao AI');
      when(() => mockMsg1.isUserMessage).thenReturn(true);

      when(() => mockMsg2.content).thenReturn('Ciao Umano');
      when(() => mockMsg2.isUserMessage).thenReturn(false);

      // Usiamo una lista fittizia di messaggi
      when(() => mockChat.messages).thenReturn([mockMsg1, mockMsg2]);
      when(() => mockViewModel.currentChat).thenReturn(mockChat);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Ciao AI'), findsOneWidget);
      expect(find.text('Ciao Umano'), findsOneWidget);
    });

    testWidgets('Allinea i messaggi correttamente a destra (Utente) o sinistra (AI)', (tester) async {
      final mockChat = MockChat();
      final userMsg = MockChatMessage();
      final aiMsg = MockChatMessage();

      when(() => userMsg.content).thenReturn('Messaggio Utente');
      when(() => userMsg.isUserMessage).thenReturn(true);

      when(() => aiMsg.content).thenReturn('Messaggio AI');
      when(() => aiMsg.isUserMessage).thenReturn(false);

      when(() => mockChat.messages).thenReturn([userMsg, aiMsg]);
      when(() => mockViewModel.currentChat).thenReturn(mockChat);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verifica allineamento messaggio utente
      final userAlignWidget = tester.widget<Align>(
        find.ancestor(
          of: find.text('Messaggio Utente'),
          matching: find.byType(Align),
        ).first,
      );
      expect(userAlignWidget.alignment, Alignment.centerRight);

      // Verifica allineamento messaggio AI
      final aiAlignWidget = tester.widget<Align>(
        find.ancestor(
          of: find.text('Messaggio AI'),
          matching: find.byType(Align),
        ).first,
      );
      expect(aiAlignWidget.alignment, Alignment.centerLeft);
    });
  });
}