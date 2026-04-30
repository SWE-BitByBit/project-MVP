import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_create_chat_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';

import '../../../../testing/mocks/chatbot/mock_chatbot_view_model.dart';

void main() {
  late MockChatbotViewModel mockViewModel;
  late MockCommand<void, void> mockCreateChat;
  late ValueNotifier<bool> isRunningNotifier;
  late GlobalKey<ScaffoldState> scaffoldKey;

  setUp(() {
    mockViewModel = MockChatbotViewModel();
    mockCreateChat = MockCommand<void, void>();
    isRunningNotifier = ValueNotifier<bool>(false);
    scaffoldKey = GlobalKey<ScaffoldState>();

    when(() => mockViewModel.createChat).thenReturn(mockCreateChat);
    when(() => mockCreateChat.isRunning).thenReturn(isRunningNotifier);
    when(() => mockCreateChat.run(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        key: scaffoldKey,
        body: const Center(child: Text('Home')),
        drawer: ChangeNotifierProvider<ChatbotViewModel>.value(
          value: mockViewModel,
          child: const Drawer(
            child: ChatbotCreateChatWidget(),
          ),
        ),
      ),
    );
  }

  group('ChatbotCreateChatWidget', () {
    testWidgets('Mostra il bottone con icona "add" e testo quando NON è in esecuzione', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      scaffoldKey.currentState?.openDrawer();
      await tester.pumpAndSettle();

      expect(find.text('Nuova conversazione'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verifica che il bottone sia abilitato
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.enabled, isTrue);
    });

    testWidgets('Mostra il CircularProgressIndicator e disabilita il bottone quando è in esecuzione', (tester) async {
      // Iniziamo con il notifier a false per permettere al drawer di aprirsi completamente senza timeout
      isRunningNotifier.value = false;

      await tester.pumpWidget(createWidgetUnderTest());
      scaffoldKey.currentState?.openDrawer();
      await tester.pumpAndSettle();

      // Attiviamo il caricamento e usiamo pump() al posto di pumpAndSettle()
      // perché il CircularProgressIndicator ha un'animazione infinita che causa il timeout
      isRunningNotifier.value = true;
      await tester.pump();

      expect(find.text('Nuova conversazione'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verifica che il bottone sia disabilitato
      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.enabled, isFalse);
    });

    testWidgets('Il tap chiude il drawer ed esegue il comando createChat', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      scaffoldKey.currentState?.openDrawer();
      await tester.pumpAndSettle();

      // Assicuriamoci che il drawer sia aperto prima del tap
      expect(find.byType(ChatbotCreateChatWidget), findsOneWidget);

      // Eseguiamo il tap
      await tester.tap(find.text('Nuova conversazione'));
      await tester.pumpAndSettle();

      // Verifica che il comando sia stato chiamato
      verify(() => mockCreateChat.run(null)).called(1);

      // Verifica che il drawer sia stato chiuso (il widget non è più nell'albero visibile)
      expect(find.byType(ChatbotCreateChatWidget), findsNothing);
    });
  });
}