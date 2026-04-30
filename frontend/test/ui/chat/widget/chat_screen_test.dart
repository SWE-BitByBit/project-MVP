import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
// Nascondiamo MockCommand da command_it per evitare conflitti con il nostro mock personalizzato
import 'package:command_it/command_it.dart' hide MockCommand;

import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/error_indicator.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chat_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/widget/chatbot_mode_info_dialog_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat.dart';


import '../../../../testing/mocks/chatbot/mock_chatbot_view_model.dart';
import '../../../../testing/mocks/chatbot/mock_chat.dart';

typedef SendMessageParam = ({Chat chat, String content, ChatMode mode});

void main() {
  late MockChatbotViewModel mockViewModel;

  // Notifiers per i vari comandi e stati reattivi
  late ValueNotifier<String?> asyncErrorNotifier;
  late ValueNotifier<bool> loadIsRunningNotifier;
  late ValueNotifier<CommandError<void>?> loadErrorsNotifier;
  late ValueNotifier<bool> openChatIsRunningNotifier;
  late ValueNotifier<bool> createChatIsRunningNotifier;
  late ValueNotifier<bool> sendMessageIsRunningNotifier;
  late ValueNotifier<CommandError<SendMessageParam>?> sendMessageErrorsNotifier;

  // Mocks per i comandi usati nello schermo e nei widget figli
  late MockCommand<void, void> mockLoadChatPreviews;
  late MockCommand<String, void> mockOpenChat;
  late MockCommand<void, void> mockCreateChat;
  late MockCommand<String, void> mockDeleteChat;
  late MockCommand<SendMessageParam, void> mockSendMessage;

  setUpAll(() {
    // Registriamo il fallback per ChatMode richiesto da mocktail per il metodo `any()`
    registerFallbackValue(ChatMode.mirror);
  });

  setUp(() {
    mockViewModel = MockChatbotViewModel();

    // Inizializzazione Notifiers con i tipi generici corretti per CommandError
    asyncErrorNotifier = ValueNotifier<String?>(null);
    loadIsRunningNotifier = ValueNotifier<bool>(false);
    loadErrorsNotifier = ValueNotifier<CommandError<void>?>(null);
    openChatIsRunningNotifier = ValueNotifier<bool>(false);
    createChatIsRunningNotifier = ValueNotifier<bool>(false);
    sendMessageIsRunningNotifier = ValueNotifier<bool>(false);
    sendMessageErrorsNotifier = ValueNotifier<CommandError<SendMessageParam>?>(null);

    // Inizializzazione Mocks Comandi
    mockLoadChatPreviews = MockCommand<void, void>();
    mockOpenChat = MockCommand<String, void>();
    mockCreateChat = MockCommand<void, void>();
    mockDeleteChat = MockCommand<String, void>();
    mockSendMessage = MockCommand<SendMessageParam, void>();

    // Setup base del ViewModel
    when(() => mockViewModel.asyncError).thenReturn(asyncErrorNotifier);
    when(() => mockViewModel.chats).thenReturn([]);
    when(() => mockViewModel.currentChat).thenReturn(null);
    when(() => mockViewModel.mode).thenReturn(ChatMode.mirror);
    when(() => mockViewModel.setMode(any())).thenReturn(null);

    // Setup mockLoadChatPreviews
    when(() => mockViewModel.loadChatPreviews).thenReturn(mockLoadChatPreviews);
    when(() => mockLoadChatPreviews.isRunning).thenReturn(loadIsRunningNotifier);
    when(() => mockLoadChatPreviews.errors).thenReturn(loadErrorsNotifier);
    when(() => mockLoadChatPreviews.run(any())).thenAnswer((_) async {});

    // Setup mockOpenChat
    when(() => mockViewModel.openChat).thenReturn(mockOpenChat);
    when(() => mockOpenChat.isRunning).thenReturn(openChatIsRunningNotifier);
    when(() => mockOpenChat.run(any())).thenAnswer((_) async {});

    // Setup mockCreateChat (usato da ChatHistoryWidget -> ChatbotCreateChatWidget)
    when(() => mockViewModel.createChat).thenReturn(mockCreateChat);
    when(() => mockCreateChat.isRunning).thenReturn(createChatIsRunningNotifier);
    when(() => mockCreateChat.run(any())).thenAnswer((_) async {});

    // Setup mockDeleteChat (usato da ChatHistoryWidget)
    when(() => mockViewModel.deleteChat).thenReturn(mockDeleteChat);
    when(() => mockDeleteChat.run(any())).thenAnswer((_) async {});

    // Setup mockSendMessage (usato da ChatbotSendMessageWidget)
    when(() => mockViewModel.sendMessage).thenReturn(mockSendMessage);
    when(() => mockSendMessage.isRunning).thenReturn(sendMessageIsRunningNotifier);
    when(() => mockSendMessage.errors).thenReturn(sendMessageErrorsNotifier);
    when(() => mockSendMessage.run(any())).thenAnswer((_) async {});
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: Scaffold(
        body: ChangeNotifierProvider<ChatbotViewModel>.value(
          value: mockViewModel,
          child: const ChatbotScreenView(),
        ),
      ),
    );
  }

  group('ChatbotScreenView', () {
    testWidgets('Mostra CircularProgressIndicator durante il caricamento iniziale vuoto', (tester) async {
      loadIsRunningNotifier.value = true;
      when(() => mockViewModel.chats).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Mostra ErrorIndicator se loadChatPreviews fallisce e la lista è vuota', (tester) async {
      loadErrorsNotifier.value = CommandError<void>(
        error: Exception('Network Error'),
        stackTrace: StackTrace.empty,
      );
      when(() => mockViewModel.chats).thenReturn([]);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ErrorIndicator), findsOneWidget);
      expect(find.text('Errore di connessione'), findsOneWidget);

      // Verifica il pulsante Riprova
      await tester.tap(find.text('Riprova'));
      verify(() => mockLoadChatPreviews.run(null)).called(1);
    });

    testWidgets('Mostra messaggio di fallback se currentChat è null', (tester) async {
      // Dati caricati ma nessuna chat selezionata
      when(() => mockViewModel.chats).thenReturn([MockChat()]);
      when(() => mockViewModel.currentChat).thenReturn(null);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Seleziona una conversazione dal menu.'), findsOneWidget);
      expect(find.byType(ChatWidget), findsNothing);
    });

    testWidgets('Mostra ChatWidget se c\'è una currentChat', (tester) async {
      final chat = MockChat();
      when(() => chat.title).thenReturn('Chat di Test');
      when(() => chat.messages).thenReturn([]);

      when(() => mockViewModel.chats).thenReturn([chat]);
      when(() => mockViewModel.currentChat).thenReturn(chat);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(ChatWidget), findsOneWidget);
      // Il titolo della chat dovrebbe apparire nella barra superiore
      expect(find.text('Chat di Test'), findsOneWidget);
    });

    testWidgets('Mostra LinearProgressIndicator quando openChat è in esecuzione', (tester) async {
      openChatIsRunningNotifier.value = true;

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('Apre la modale informativa al tap sull\'icona info', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      expect(find.byType(ChatbotModeInfoDialog), findsOneWidget);
    });

    testWidgets('Mostra una SnackBar quando asyncError emette un valore', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Triggeriamo l'errore asincrono
      asyncErrorNotifier.value = "Errore di connessione al server AI";
      await tester.pump(); // Usiamo pump e non pumpAndSettle per dare tempo alla SnackBar di apparire

      expect(find.text('Errore di connessione al server AI'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
