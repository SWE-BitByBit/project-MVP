import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/message_response.dart';

void main() {
  group('MessageResponse - Entità di Dominio', () {

    // Prepariamo un messaggio standard da usare nei test
    final dummyAiMessage = ChatMessage(
      id: 'msg-ai-1',
      content: 'Risposta di prova',
      type: MessageType.AI,
      timestamp: DateTime.now(),
    );

    test('Deve restituire il messaggio e un titolo nullo se non viene fornito un nuovo titolo', () {
      // Arrange: Creiamo la risposta solo con il parametro obbligatorio
      final response = MessageResponse(response: dummyAiMessage);

      // Assert: Il messaggio c'è, ma il titolo deve essere null
      expect(response.getResponse(), equals(dummyAiMessage));
      expect(response.getUpdatedTitle(), isNull);
    });

    test('Deve restituire sia il messaggio che il titolo aggiornato se forniti entrambi', () {
      // Arrange: Creiamo la risposta passando anche il parametro opzionale
      final response = MessageResponse(
        response: dummyAiMessage,
        updatedTitle: 'Nuova Indagine',
      );

      // Assert
      expect(response.getResponse(), equals(dummyAiMessage));
      expect(response.getUpdatedTitle(), 'Nuova Indagine');
    });

  });
}