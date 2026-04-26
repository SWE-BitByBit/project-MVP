import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/chatbot_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';

import '../../../testing/mocks/mock_chatbot_service.dart';

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

    test(
      'getChatPreviews mappa correttamente il JSON in oggetti Chat',
      () async {
        // Arrange: Prepariamo un finto JSON di risposta dal Service
        mockService.mockedPreviewsJson = [
          {
            'id': 'prev-1',
            'title': 'Indagine 1',
            'lastModified': sampleDateString,
          },
        ];

        // Act
        final previews = await repository.getChatPreviews();

        // Assert: Verifichiamo che il Repository abbia fatto bene la traduzione
        expect(previews.length, 1);
        expect(previews.first.getId(), 'prev-1');
        expect(previews.first.getTitle(), 'Indagine 1');
        expect(previews.first.getCreationDate(), sampleDate);
      },
    );

    test('getChatById delega al ChatDTO per il parsing', () async {
      // Arrange
      mockService.mockedChatJson = {
        'id': 'chat-1',
        'title': 'Chat Completa',
        'creationDate': sampleDateString,
        'messages': [], // Testiamo una chat vuota per semplicità
      };

      // Act
      final chat = await repository.getChatById('chat-1');

      // Assert
      expect(chat.getId(), 'chat-1');
      expect(chat.getTitle(), 'Chat Completa');
    });

    test('sendMessage mappa correttamente la risposta', () async {
      // Arrange: Creiamo una chat finta da passare come parametro
      final dummyChat = LocalChat(
        id: 'chat-99',
        title: 'Vecchia',
        creationDate: DateTime.now(),
        messages: [],
      );

      // Act
      final response = await repository.sendMessage(
        dummyChat,
        'Ciao',
        ChatMode.detective,
      );

      // Assert: Controlliamo il messaggio
      final msg = response.getResponse();
      expect(msg.content, 'Questa è la mia risposta');
    });

    // Test degli Errori (Essenziale per la Coverage)
    test(
      'Se il Service lancia un\'eccezione, il Repository la lascia passare verso il ViewModel',
      () async {
        mockService.shouldThrowError = true;

        // Usiamo 'throwsException' per verificare che l'errore arrivi fino a noi
        expect(() => repository.getChatPreviews(), throwsException);
        expect(() => repository.createChat(), throwsException);
      },
    );
  });
}
