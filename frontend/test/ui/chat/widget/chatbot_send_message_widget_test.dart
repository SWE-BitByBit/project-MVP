import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_send_message_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat.dart';

import '../../../../testing/mocks/chatbot/mock_chatbot_view_model.dart';
import '../../../../testing/mocks/chatbot/mock_chat.dart';

typedef SendMessageParam = ({Chat chat, String content, ChatMode mode});

class FakeChat extends Fake implements Chat {}

void main() {
  late MockChatbotViewModel mockViewModel;
  late MockCommand<SendMessageParam, void> mockSendMessage;
  late ValueNotifier<bool> isRunningNotifier;
  late MockChat mockChat;

  setUpAll(() {
    registerFallbackValue(ChatMode.mirror);
    registerFallbackValue((chat: FakeChat(), content: '', mode: ChatMode.mirror));
  });

  setUp(() {
    mockViewModel = MockChatbotViewModel();
    mockSendMessage = MockCommand<SendMessageParam, void>();
    isRunningNotifier = ValueNotifier<bool>(false);
    mockChat = MockChat();

    when(() => mockViewModel.sendMessage).thenReturn(mockSendMessage);
    when(() => mockSendMessage.isRunning).thenReturn(isRunningNotifier);
    when(() => mockSendMessage.run(any())).thenAnswer((_) async {});

    // Valori di default
    when(() => mockViewModel.mode).thenReturn(ChatMode.detective);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<ChatbotViewModel>.value(
          value: mockViewModel,
          child: const ChatbotSendMessageWidget(),
        ),
      ),
    );
  }

  group('ChatbotSendMessageWidget', () {
    testWidgets('Disabilita input e bottone se non c\'è una chat attiva', (tester) async {
      when(() => mockViewModel.currentChat).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verifica Testo Placeholder
      expect(find.text('Seleziona una chat prima'), findsOneWidget);

      // Verifica che il TextField sia disabilitato
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);

      // Verifica che il bottone di invio sia disabilitato
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('Abilita input ma disabilita bottone se la chat è attiva ma il testo è vuoto', (tester) async {
      when(() => mockViewModel.currentChat).thenReturn(mockChat);

      await tester.pumpWidget(createWidgetUnderTest());

      // Verifica Testo Placeholder
      expect(find.text('Scrivi un messaggio...'), findsOneWidget);

      // Verifica che il TextField sia abilitato
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isTrue);

      // Verifica che il bottone di invio sia ancora disabilitato (nessun testo)
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });

    testWidgets('Abilita il bottone di invio quando c\'è del testo e una chat attiva', (tester) async {
      when(() => mockViewModel.currentChat).thenReturn(mockChat);

      await tester.pumpWidget(createWidgetUnderTest());

      // Inseriamo del testo
      await tester.enterText(find.byType(TextField), 'Ciao AI');
      await tester.pump();

      // Verifica che il bottone di invio sia abilitato
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNotNull);
    });

    testWidgets('L\'invio del messaggio esegue il comando e svuota il campo di testo', (tester) async {
      when(() => mockViewModel.currentChat).thenReturn(mockChat);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), 'Messaggio di prova');
      await tester.pump();

      await tester.tap(find.byType(IconButton));
      await tester.pump();

      // Verifica l'esecuzione del comando con i parametri esatti
      verify(() => mockSendMessage.run((
      chat: mockChat,
      content: 'Messaggio di prova',
      mode: ChatMode.detective,
      ))).called(1);

      // Verifica che il campo di testo sia stato svuotato
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('Mostra indicatore di caricamento e disabilita bottone durante l\'invio', (tester) async {
      when(() => mockViewModel.currentChat).thenReturn(mockChat);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), 'Testo');
      await tester.pump();

      // Attiviamo lo stato di caricamento
      isRunningNotifier.value = true;
      await tester.pump();

      // Verifica la presenza dell'indicatore di caricamento al posto dell'icona
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.send_rounded), findsNothing);

      // Verifica che il bottone sia disabilitato durante l'invio
      final iconButton = tester.widget<IconButton>(find.byType(IconButton));
      expect(iconButton.onPressed, isNull);
    });
  });
}