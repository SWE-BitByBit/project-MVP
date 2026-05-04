import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chat_history_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';

import '../../../../testing/mocks/chatbot/mock_chatbot_view_model.dart';
import '../../../../testing/mocks/chatbot/mock_chat.dart';

void main() {
  late MockChatbotViewModel mockViewModel;
  late MockCommand<String, void> mockOpenChat;
  late MockCommand<String, void> mockDeleteChat;
  late MockCommand<void, void> mockCreateChat;
  late GlobalKey<ScaffoldState> scaffoldKey;

  // Notifier per evitare l'eccezione di tipo Null sul ValueListenable
  late ValueNotifier<bool> createChatIsRunningNotifier;

  setUp(() {
    mockViewModel = MockChatbotViewModel();
    mockOpenChat = MockCommand<String, void>();
    mockDeleteChat = MockCommand<String, void>();
    mockCreateChat = MockCommand<void, void>();

    createChatIsRunningNotifier = ValueNotifier<bool>(false);

    scaffoldKey = GlobalKey<ScaffoldState>();

    // Mock dei comandi principali
    when(() => mockViewModel.openChat).thenReturn(mockOpenChat);
    when(() => mockViewModel.deleteChat).thenReturn(mockDeleteChat);
    when(() => mockViewModel.createChat).thenReturn(mockCreateChat);

    // Setup essenziale per il widget figlio ChatbotCreateChatWidget che ascolta isRunning
    when(
      () => mockCreateChat.isRunning,
    ).thenReturn(createChatIsRunningNotifier);

    when(() => mockOpenChat.run(any())).thenAnswer((_) async {});
    when(() => mockDeleteChat.run(any())).thenAnswer((_) async {});
    when(() => mockCreateChat.run()).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        drawer: ChangeNotifierProvider<ChatbotViewModel>.value(
          value: mockViewModel,
          child: const ChatHistoryWidget(),
        ),
        body: const Center(child: Text('Home')),
      ),
    );
  }

  group('ChatHistoryWidget', () {
    testWidgets('Mostra messaggio di stato vuoto se non ci sono chat', (
      tester,
    ) async {
      when(() => mockViewModel.chats).thenReturn([]);
      when(() => mockViewModel.currentChat).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      scaffoldKey.currentState?.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Nessuna conversazione salvata.'), findsOneWidget);
      expect(find.byType(ListTile), findsNothing);
    });

    testWidgets('Mostra la lista delle chat', (tester) async {
      final chat1 = MockChat();
      when(() => chat1.id).thenReturn('1');
      when(() => chat1.title).thenReturn('Chat uno');

      final chat2 = MockChat();
      when(() => chat2.id).thenReturn('2');
      when(() => chat2.title).thenReturn('Chat due');

      when(() => mockViewModel.chats).thenReturn([chat1, chat2]);
      when(() => mockViewModel.currentChat).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      scaffoldKey.currentState?.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Chat uno'), findsOneWidget);
      expect(find.text('Chat due'), findsOneWidget);
      expect(find.byType(ListTile), findsNWidgets(2));
    });

    testWidgets(
      'Il tap su una chat invia il comando openChat e chiude il drawer',
      (tester) async {
        final chat1 = MockChat();
        when(() => chat1.id).thenReturn('1');
        when(() => chat1.title).thenReturn('Chat di test');

        when(() => mockViewModel.chats).thenReturn([chat1]);
        when(() => mockViewModel.currentChat).thenReturn(null);

        await tester.pumpWidget(createWidgetUnderTest());
        scaffoldKey.currentState?.openDrawer();
        await tester.pumpAndSettle();

        // Tappiamo sulla riga della chat
        await tester.tap(find.text('Chat di test'));
        await tester
            .pumpAndSettle(); // Aspettiamo l'animazione di chiusura del drawer

        // Verifica comando
        verify(() => mockOpenChat.run('1')).called(1);

        // Verifica che il drawer sia stato chiuso (il testo non è più visibile/attivo nello scaffold)
        expect(find.text('Cronologia Chat'), findsNothing);
      },
    );

    testWidgets('Il tap sull\'icona cestino invia il comando deleteChat', (
      tester,
    ) async {
      final chat1 = MockChat();
      when(() => chat1.id).thenReturn('1');
      when(() => chat1.title).thenReturn('Chat da eliminare');

      when(() => mockViewModel.chats).thenReturn([chat1]);
      when(() => mockViewModel.currentChat).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());
      scaffoldKey.currentState?.openDrawer();
      await tester.pumpAndSettle();

      final dots_btns = find.byIcon(Icons.more_vert);
      await tester.tap(dots_btns.first);
      await tester.pumpAndSettle();

      // Troviamo tutti i bottoni "cestino"
      final delete_btns = find.byIcon(Icons.delete_outline);
      await tester.tap(delete_btns.first);
      await tester.pumpAndSettle();

      // Clicchiamo il pulsante 'Elimina' nel dialogo di conferma
      await tester.tap(find.widgetWithText(ElevatedButton, 'Elimina'));

      await tester.pumpAndSettle();

      verify(() => mockDeleteChat.run('1')).called(1);
    });
  });
}
