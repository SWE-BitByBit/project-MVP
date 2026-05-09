import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/proxies/proxy_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';

import '../../../testing/mocks/chatbot/mock_chatbot_repository.dart';

void main() {
  late MockChatbotRepository mockRepository;
  late ProxyChat proxyChat;

  final creationDate = DateTime(2023, 1, 1);
  final updateDate = DateTime(2023, 1, 2);

  setUp(() {
    mockRepository = MockChatbotRepository();
    proxyChat = ProxyChat(
      id: 'chat_proxy_1',
      title: 'Anteprima Titolo',
      creationDate: creationDate,
      updateDate: updateDate,
      repository: mockRepository,
    );
  });

  group('ProxyChat Tests', () {
    test('dovrebbe restituire i dati cache iniziali e una lista messaggi vuota prima del load (Lazy Loading)', () {
      // Assert
      expect(proxyChat.id, 'chat_proxy_1');
      expect(proxyChat.title, 'Anteprima Titolo');
      expect(proxyChat.creationDate, creationDate);
      expect(proxyChat.updateDate, updateDate);
      expect(proxyChat.messages, isEmpty);
      verifyNever(() => mockRepository.getChatById(any()));
    });

    test('dovrebbe scaricare i dati dal repository e delegare a LocalChat dopo il load', () async {
      // Arrange
      final loadedUpdateDate = DateTime(2023, 1, 10);
      final localChat = LocalChat(
        id: 'chat_proxy_1',
        title: 'Titolo Definitivo',
        creationDate: creationDate,
        updateDate: loadedUpdateDate,
        messages: [
          ChatMessage(
            id: 'msg_1',
            content: 'Ciao',
            type: MessageType.user,
            timestamp: loadedUpdateDate,
          )
        ],
      );

      when(() => mockRepository.getChatById('chat_proxy_1'))
          .thenAnswer((_) async => localChat);

      // Act
      await proxyChat.load();

      // Assert
      expect(proxyChat.title, 'Titolo Definitivo');
      expect(proxyChat.updateDate, loadedUpdateDate);
      expect(proxyChat.messages.length, 1);
      expect(proxyChat.messages.first.content, 'Ciao');
      verify(() => mockRepository.getChatById('chat_proxy_1')).called(1);
    });

    test('non dovrebbe chiamare il repository più di una volta se i dati sono già caricati', () async {
      // Arrange
      final localChat = LocalChat(
        id: 'chat_proxy_1',
        title: 'Titolo Definitivo',
        creationDate: creationDate,
        updateDate: updateDate,
        messages: [],
      );

      when(() => mockRepository.getChatById('chat_proxy_1'))
          .thenAnswer((_) async => localChat);

      // Act
      await proxyChat.load();
      await proxyChat.load(); // Seconda chiamata

      // Assert
      verify(() => mockRepository.getChatById('chat_proxy_1')).called(1); // Chiamato solo 1 volta
    });

    test('dovrebbe propagare le modifiche al titolo sia al proxy che al LocalChat sottostante', () async {
      // Arrange
      final localChat = LocalChat(
        id: 'chat_proxy_1',
        title: 'Vecchio Titolo',
        creationDate: creationDate,
        updateDate: updateDate,
        messages: [],
      );

      when(() => mockRepository.getChatById('chat_proxy_1'))
          .thenAnswer((_) async => localChat);

      // Act 1: Modifica prima del caricamento
      proxyChat.title = 'Nuovo Titolo Proxy';
      expect(proxyChat.title, 'Nuovo Titolo Proxy');

      // Act 2: Caricamento
      await proxyChat.load();

      // Act 3: Modifica dopo il caricamento
      proxyChat.title = 'Titolo Sincronizzato';

      // Assert
      expect(proxyChat.title, 'Titolo Sincronizzato');
      expect(localChat.title, 'Titolo Sincronizzato');
    });

    test('dovrebbe delegare addMessage al LocalChat solo se caricato', () async {
      // Arrange
      final localChat = LocalChat(
        id: 'chat_proxy_1',
        title: 'Titolo',
        creationDate: creationDate,
        updateDate: updateDate,
        messages: [],
      );

      when(() => mockRepository.getChatById('chat_proxy_1'))
          .thenAnswer((_) async => localChat);

      final message = ChatMessage(
        id: 'msg_test',
        content: 'Test',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );

      // Act 1: Aggiunta prima del load (verrà ignorata perché _localChat è null)
      proxyChat.addMessage(message);
      expect(proxyChat.messages, isEmpty); // Non fa crashare ma non salva

      // Act 2: Load
      await proxyChat.load();

      // Act 3: Aggiunta dopo il load
      proxyChat.addMessage(message);

      // Assert
      expect(proxyChat.messages.length, 1);
      expect(localChat.messages.length, 1);
    });
  });
}