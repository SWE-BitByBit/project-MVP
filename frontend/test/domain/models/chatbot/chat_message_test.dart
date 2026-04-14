import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';

void main() {
  group('ChatMessage - Entità di Dominio', () {

    test('isUserMessage deve restituire true solo per i messaggi dell\'utente', () {
      // Arrange: Creiamo un messaggio di tipo USER
      final userMessage = ChatMessage(
        id: 'user-1',
        content: 'Ciao AI!',
        type: MessageType.USER,
        timestamp: DateTime.now(),
      );

      // Assert: Verifichiamo che i controlli booleani funzionino
      expect(userMessage.isUserMessage(), isTrue);
      expect(userMessage.isAiMessage(), isFalse);
    });

    test('isAiMessage deve restituire true solo per i messaggi dell\'AI', () {
      // Arrange: Creiamo un messaggio di tipo AI
      final aiMessage = ChatMessage(
        id: 'ai-1',
        content: 'Ciao Umano!',
        type: MessageType.AI,
        timestamp: DateTime.now(),
      );

      // Assert
      expect(aiMessage.isAiMessage(), isTrue);
      expect(aiMessage.isUserMessage(), isFalse);
    });

  });
}