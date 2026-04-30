import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/proxy_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import '../../../../testing/mocks/mock_chatbot_repository.dart';

void main() {
  group('ProxyChat Tests', () {
    late MockChatbotRepository mockRepository;
    late ProxyChat proxyChat;
    final creationDate = DateTime(2024, 1, 1);

    setUp(() {
      mockRepository = MockChatbotRepository();
      proxyChat = ProxyChat(
        id: 'chat-1',
        title: 'Proxy Title',
        creationDate: creationDate,
        repository: mockRepository,
      );
    });

    test('Initial state is not loaded', () {
      expect(proxyChat.isLoaded(), isFalse);
      expect(proxyChat.getId(), 'chat-1');
      expect(proxyChat.getTitle(), 'Proxy Title');
      expect(proxyChat.getCreationDate(), creationDate);
      expect(proxyChat.getUpdateDate(), creationDate);
      expect(proxyChat.getMessages(), isEmpty);
    });

    test('load() successfully transforms to LocalChat', () async {
      final localChat = LocalChat(
        id: 'chat-1',
        title: 'Loaded Title',
        creationDate: creationDate,
        messages: [
          ChatMessage(
            id: 'msg-1',
            content: 'Hello',
            type: MessageType.user,
            timestamp: DateTime.now(),
          ),
        ],
      );
      mockRepository.mockedChatToReturn = localChat;

      await proxyChat.load();

      expect(proxyChat.isLoaded(), isTrue);
      expect(proxyChat.getTitle(), 'Loaded Title');
      expect(proxyChat.getMessages().length, 1);
    });

    test('load() does nothing if already loaded', () async {
      mockRepository.mockedChatToReturn = LocalChat(
        id: 'chat-1',
        title: 'Title',
        creationDate: creationDate,
        messages: [],
      );

      await proxyChat.load();
      final firstLoad = proxyChat.isLoaded();
      
      await proxyChat.load();
      
      expect(firstLoad, isTrue);
      expect(proxyChat.isLoaded(), isTrue);
    });

    test('addMessage() initializes LocalChat if not loaded', () {
      final message = ChatMessage(
        id: 'msg-new',
        content: 'New message',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      proxyChat.addMessage(message);

      expect(proxyChat.isLoaded(), isTrue);
      expect(proxyChat.getMessages().length, 1);
      expect(proxyChat.getMessages().first.content, 'New message');
    });

    test('setTitle() updates both proxy and LocalChat', () async {
      proxyChat.setTitle('New Title');
      expect(proxyChat.getTitle(), 'New Title');

      // Now load and check if LocalChat has it
      final localChat = LocalChat(
        id: 'chat-1',
        title: 'Title from Repo',
        creationDate: creationDate,
        messages: [],
      );
      mockRepository.mockedChatToReturn = localChat;
      await proxyChat.load();
      
      proxyChat.setTitle('Final Title');
      expect(proxyChat.getTitle(), 'Final Title');
      expect(localChat.getTitle(), 'Final Title');
    });
    
    test('getTitle returns _localChat title if loaded', () async {
        mockRepository.mockedChatToReturn = LocalChat(
          id: 'chat-1',
          title: 'Title from Repo',
          creationDate: creationDate,
          messages: [],
        );
        await proxyChat.load();
        expect(proxyChat.getTitle(), 'Title from Repo');
    });

    test('getUpdateDate returns _localChat update date if loaded', () async {
        final localChat = LocalChat(
          id: 'chat-1',
          title: 'Title',
          creationDate: creationDate,
          messages: [],
        );
        localChat.setTitle('Updated');
        
        mockRepository.mockedChatToReturn = localChat;
        await proxyChat.load();
        
        expect(proxyChat.getUpdateDate(), localChat.getUpdateDate());
    });
  });
}
