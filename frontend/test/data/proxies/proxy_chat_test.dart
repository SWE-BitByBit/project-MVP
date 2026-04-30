import 'package:flutter_test/flutter_test.dart';

// Sostituisci con i tuoi percorsi
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/data/proxies/proxy_chat.dart'; // Metti il percorso corretto

// Il nostro Mock
import '../../../testing/mocks/mock_chatbot_repository.dart';

void main() {
  group('ProxyChat - Virtual Proxy Pattern', () {
    late MockChatbotRepository mockRepo;
    late ProxyChat proxyChat;

    final sampleDate = DateTime(2024, 1, 1);

    setUp(() {
      mockRepo = MockChatbotRepository();

      // Creiamo un Proxy "scarico"
      proxyChat = ProxyChat(
        id: 'chat-100',
        title: 'Titolo Provvisorio',
        creationDate: sampleDate,
        lastModified: sampleDate,
        repository: mockRepo,
      );
    });

    test('Prima del load() restituisce i dati base e una lista messaggi vuota', () {
      expect(proxyChat.getId(), 'chat-100');
      expect(proxyChat.getTitle(), 'Titolo Provvisorio');
      expect(proxyChat.getCreationDate(), sampleDate);
      expect(proxyChat.getMessages(), isEmpty); // La vera magia del Proxy!
    });

    test('Dopo il load() si sincronizza con la LocalChat reale', () async {
      // 1. Arrange: Prepariamo la chat "pesante" che il server dovrebbe restituire
      final chatScaricataDalServer = LocalChat(
        id: 'chat-100',
        title: 'Titolo Vero Aggiornato',
        creationDate: sampleDate,
        messages: [
          ChatMessage(
            id: 'msg-1',
            content: 'Sono un messaggio pesantissimo',
            type: MessageType.ai,
            timestamp: sampleDate,
          )
        ],
      );

      // Diciamo al mock di restituire questa chat
      mockRepo.mockedChatToReturn = chatScaricataDalServer;

      // 2. Act: Diciamo al Proxy di scaricare i dati
      await proxyChat.load();

      // 3. Assert: Verifichiamo che i dati siano stati "sovrascritti" da quelli reali
      expect(proxyChat.getTitle(), 'Titolo Vero Aggiornato');

      final messaggi = proxyChat.getMessages();
      expect(messaggi.length, 1);
      expect(messaggi.first.content, 'Sono un messaggio pesantissimo');
    });

    test('I metodi di modifica vengono delegati correttamente dopo il load()', () async {
      // Prepariamo il mock
      mockRepo.mockedChatToReturn = LocalChat(
        id: 'chat-100',
        title: 'Titolo Iniziale',
        creationDate: sampleDate,
        messages: [],
      );

      // Carichiamo il proxy
      await proxyChat.load();

      // Testiamo l'aggiornamento del titolo
      proxyChat.setTitle('Titolo Modificato Dall\'Utente');
      expect(proxyChat.getTitle(), 'Titolo Modificato Dall\'Utente');

      // Testiamo l'inserimento di un messaggio
      final userMessage = ChatMessage(
        id: 'msg-user',
        content: 'Ciao!',
        type: MessageType.user,
        timestamp: DateTime.now(),
      );
      proxyChat.addMessage(userMessage);

      expect(proxyChat.getMessages().length, 1);
      expect(proxyChat.getMessages().first.content, 'Ciao!');
    });
  });
}
