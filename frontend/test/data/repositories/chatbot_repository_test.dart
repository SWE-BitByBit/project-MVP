import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/chatbot_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';


import '../../../testing/mocks/chatbot/mock_chatbot_service.dart';

void main() {
  group('ChatbotRepository', () {
    late MockChatbotService mockService;
    late ChatbotRepository repository;

    final sampleDateString = '2024-05-20T14:30:00.000';
    final sampleDate = DateTime.parse(sampleDateString);

    setUp(() {
      mockService = MockChatbotService();
      repository = ChatbotRepository(mockService);
    });

    test('getChatPreviews mappa correttamente il JSON in oggetti ChatPreview', () async {
      // Arrange: Prepariamo un finto JSON di risposta dal Service
      mockService.mockedPreviewsJson = [
        {
          'id': 'prev-1',
          'title': 'Indagine 1',
          'lastModified': sampleDateString,
        }
      ];

      // Act
      final previews = await repository.getChatPreviews();

      // Assert: Verifichiamo che il Repository abbia fatto bene la traduzione
      expect(previews.length, 1);
      expect(previews.first.id, 'prev-1');
      expect(previews.first.title, 'Indagine 1');
      expect(previews.first.lastModified, sampleDate);
    });

    test('getChatById delega al ChatDTO per il parsing', () async {
      // Arrange
      mockService.mockedChatJson = {
        'id': 'chat-1',
        'title': 'Chat Completa',
        'creationDate': sampleDateString,
        'messages': [] // Testiamo una chat vuota per semplicità
      };

      // Act
      final chat = await repository.getChatById('chat-1');

      // Assert
      expect(chat.getId(), 'chat-1');
      expect(chat.getTitle(), 'Chat Completa');
    });

    test('sendMessage mappa correttamente la risposta e gestisce il titolo opzionale', () async {
      // Arrange: Creiamo una chat finta da passare come parametro
      final dummyChat = LocalChat(
          id: 'chat-99',
          title: 'Vecchia',
          creationDate: DateTime.now(),
          messages: []
      );

      // Prepariamo la risposta del Service
      mockService.mockedMessageResponseJson = {
        'id': 'msg-ai-1',
        'content': 'Questa è la mia risposta',
        'type': 'AI',
        'timestamp': sampleDateString,
        'updatedTitle': 'Nuovo Titolo Indagine' // Testiamo che recuperi il nuovo titolo
      };

      // Act
      final response = await repository.sendMessage(dummyChat, 'Ciao', ChatMode.DETECTIVE);

      // Assert: Controlliamo il messaggio
      final msg = response.getResponse();
      expect(msg.id, 'msg-ai-1');
      expect(msg.content, 'Questa è la mia risposta');
      expect(msg.isAiMessage(), isTrue);
      expect(msg.timestamp, sampleDate);

      // Controlliamo il titolo aggiornato
      expect(response.getUpdatedTitle(), 'Nuovo Titolo Indagine');
    });

    // Test degli Errori (Essenziale per la Coverage)
    test('Se il Service lancia un\'eccezione, il Repository la lascia passare verso il ViewModel', () async {
      mockService.shouldThrowError = true;

      // Usiamo 'throwsException' per verificare che l'errore arrivi fino a noi
      expect(() => repository.getChatPreviews(), throwsException);
      expect(() => repository.createChat(), throwsException);
    });
  });
}