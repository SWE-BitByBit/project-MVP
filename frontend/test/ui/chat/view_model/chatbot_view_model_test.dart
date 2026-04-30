import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/chat/view_model/chatbot_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';

import '../../../../testing/mocks/auth/mock_auth_repository.dart';
import '../../../../testing/mocks/chatbot/mock_chatbot_repository.dart';
import '../../../../testing/mocks/chatbot/mock_proxy_chat.dart';
import '../../../../testing/mocks/chatbot/mock_message_response.dart';

class FakeUser extends Fake implements User {}
class FakeChat extends Fake implements Chat {}

class FakeMutableChat extends Fake implements Chat {
  @override
  final String id = 'fake_real_chat';
  @override
  String title = 'Test';
  @override
  final List<ChatMessage> messages = [];

  @override
  void addMessage(ChatMessage message) {
    messages.add(message);
  }
}

void main() {
  late ChatbotViewModel viewModel;
  late MockChatbotRepository mockChatbotRepository;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(FakeChat());
    registerFallbackValue(ChatMode.mirror);
  });

  setUp(() {
    Command.globalExceptionHandler = (error, stackTrace) {};

    mockChatbotRepository = MockChatbotRepository();
    mockAuthRepository = MockAuthRepository();

    when(() => mockAuthRepository.getCurrentUser()).thenReturn(FakeUser());
    when(() => mockChatbotRepository.cachedChats).thenReturn([]);
    when(() => mockChatbotRepository.getChatPreviews()).thenAnswer((_) async {return [];});
    when(() => mockChatbotRepository.lastViewedChatId).thenReturn(null);
  });

  Future<void> initViewModel() async {
    viewModel = ChatbotViewModel(
      mockChatbotRepository,
      authRepository: mockAuthRepository,
    );
    await viewModel.loadChatPreviews.runAsync();
  }

  group('ChatbotViewModel - Inizializzazione e Stato', () {
    test('Costruttore dovrebbe caricare le preview e creare chat virtuale se lista vuota', () async {
      await initViewModel();

      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verify(() => mockChatbotRepository.getChatPreviews()).called(1);
      expect(viewModel.chats, isEmpty);
      expect(viewModel.currentChat, isNotNull);
      expect(viewModel.currentChat, isA<LocalChat>());
      expect(viewModel.currentChat!.id, startsWith('virtual_'));
      expect(viewModel.mode, ChatMode.mirror);
    });

    test('Non deve caricare preview se utente non è loggato', () async {
      when(() => mockAuthRepository.getCurrentUser()).thenReturn(null);

      await initViewModel();

      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verifyNever(() => mockChatbotRepository.getChatPreviews());
    });

    test('Dovrebbe aprire lastViewedChatId se presente e valido', () async {
      final mockChat = LocalChat(
        id: 'chat_1',
        title: 'Test',
        creationDate: DateTime.now(),
        updateDate: DateTime.now(),
        messages: <ChatMessage>[],
      );
      when(() => mockChatbotRepository.cachedChats).thenReturn([mockChat]);
      when(() => mockChatbotRepository.lastViewedChatId).thenReturn('chat_1');
      when(() => mockChatbotRepository.lastViewedChatId = any()).thenReturn(null);

      await initViewModel();

      expect(viewModel.currentChat?.id, 'chat_1');
    });

    test('setMode non dovrebbe notificare se la modalità è identica a quella di default (mirror)', () async {
      await initViewModel();

      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      viewModel.setMode(ChatMode.mirror);

      expect(viewModel.mode, ChatMode.mirror);
      expect(notifyCount, 0);
    });
  });

  group('ChatbotViewModel - Azioni Chat', () {
    test('createChat dovrebbe creare una nuova chat virtuale', () async {
      await initViewModel();
      final oldChatId = viewModel.currentChat?.id;

      // Un piccolo delay per garantire che DateTime.now().millisecondsSinceEpoch generi un ID diverso
      await Future.delayed(const Duration(milliseconds: 2));

      await viewModel.createChat.runAsync();

      expect(viewModel.currentChat?.id, isNot(oldChatId));
      expect(viewModel.currentChat!.id, startsWith('virtual_'));
    });

    test('openChat con ProxyChat dovrebbe chiamare load() sul proxy', () async {
      final proxyChat = MockProxyChat();
      when(() => proxyChat.id).thenReturn('proxy_1');
      when(() => proxyChat.load()).thenAnswer((_) async {});
      when(() => mockChatbotRepository.cachedChats).thenReturn([proxyChat]);
      when(() => mockChatbotRepository.lastViewedChatId = any()).thenReturn(null);

      await initViewModel();
      await viewModel.openChat.runAsync('proxy_1');

      verify(() => proxyChat.load()).called(1);
      verify(() => mockChatbotRepository.lastViewedChatId = 'proxy_1').called(1);
      expect(viewModel.currentChat, proxyChat);
    });

    test('deleteChat dovrebbe eliminare la chat e resettare se era quella corrente', () async {
      await initViewModel();
      final currentVirtualId = viewModel.currentChat!.id;

      when(() => mockChatbotRepository.deleteChat(currentVirtualId)).thenAnswer((_) async {});

      // Un piccolo delay per garantire che la nuova chat virtuale creata nel fallback abbia un ID diverso
      await Future.delayed(const Duration(milliseconds: 2));

      await viewModel.deleteChat.runAsync(currentVirtualId);

      verify(() => mockChatbotRepository.deleteChat(currentVirtualId)).called(1);
      expect(viewModel.currentChat!.id, isNot(currentVirtualId));
      expect(viewModel.currentChat!.id, startsWith('virtual_'));
    });

    test('deleteChat in errore imposta asyncError', () async {
      await initViewModel();

      when(() => mockChatbotRepository.deleteChat('error_id'))
          .thenAnswer((_) async => throw Exception('Delete fallita'));

      try {
        await viewModel.deleteChat.runAsync('error_id');
      } catch (_) {}

      await Future.delayed(Duration.zero);

      expect(viewModel.asyncError.value, 'Impossibile eliminare la chat.');
    });
  });

  group('ChatbotViewModel - Invio Messaggi', () {
    test('sendMessage su chat virtuale crea chat reale prima di inviare', () async {
      await initViewModel();
      final virtualChat = viewModel.currentChat as LocalChat;

      final realChat = LocalChat(
        id: 'real_1',
        title: 'Nuova',
        creationDate: DateTime.now(),
        updateDate: DateTime.now(),
        messages: <ChatMessage>[],
      );
      final mockResponse = MockMessageResponse();
      final replyMsg = ChatMessage(
        id: 'reply_1',
        content: 'Risposta',
        type: MessageType.ai,
        timestamp: DateTime.now(),
      );

      when(() => mockResponse.response).thenReturn(replyMsg);
      when(() => mockResponse.updatedTitle).thenReturn('Titolo Aggiornato');

      when(() => mockChatbotRepository.createChat()).thenAnswer((_) async => realChat);
      when(() => mockChatbotRepository.lastViewedChatId = any()).thenReturn(null);
      when(() => mockChatbotRepository.sendMessage(any(), any(), any()))
          .thenAnswer((_) async => mockResponse);

      await viewModel.sendMessage.runAsync((chat: virtualChat, content: 'Ciao', mode: ChatMode.mirror));

      verify(() => mockChatbotRepository.createChat()).called(1);
      verify(() => mockChatbotRepository.sendMessage(any(), 'Ciao', ChatMode.mirror)).called(1);

      expect(viewModel.currentChat, realChat);
      expect(realChat.title, 'Titolo Aggiornato');
    });

    test('sendMessage fallback: imposta asyncError se API fallisce e rimuove messaggio finto', () async {
      await initViewModel();

      final fakeChat = FakeMutableChat();

      when(() => mockChatbotRepository.sendMessage(any(), any(), any()))
          .thenAnswer((_) async => throw Exception('Errore di rete'));

      try {
        await viewModel.sendMessage.runAsync((chat: fakeChat, content: 'Fail', mode: ChatMode.mirror));
      } catch (_) {}

      await Future.delayed(Duration.zero);

      expect(viewModel.asyncError.value, 'Errore nell\'invio del messaggio.');
      expect(fakeChat.messages, isEmpty);
    });
  });
}