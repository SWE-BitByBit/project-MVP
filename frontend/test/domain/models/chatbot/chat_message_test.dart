import 'package:flutter_test/flutter_test.dart';

// NOTA: Sostituisci questi import con i percorsi reali del tuo progetto
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';

void main() {
  group('ChatMessage - Initialization', () {
    test('should initialize correctly with all provided parameters', () {
      // Arrange
      final timestamp = DateTime(2023, 1, 1, 12, 0, 0);

      // Act
      final message = ChatMessage(
        id: 'msg_001',
        content: 'Ciao AI!',
        type: MessageType.user,
        timestamp: timestamp,
      );

      // Assert
      expect(message.id, 'msg_001');
      expect(message.content, 'Ciao AI!');
      expect(message.type, MessageType.user);
      expect(message.timestamp, timestamp);
    });
  });

  group('ChatMessage - Getters (isUserMessage & isAiMessage)', () {
    final timestamp = DateTime.now();

    test('isUserMessage should return true and isAiMessage false when type is user', () {
      // Arrange
      final message = ChatMessage(
        id: 'msg_user',
        content: 'Testo utente',
        type: MessageType.user,
        timestamp: timestamp,
      );

      // Act
      final isUser = message.isUserMessage;
      final isAi = message.isAiMessage;

      // Assert
      expect(isUser, isTrue);
      expect(isAi, isFalse);
    });

    test('isAiMessage should return true and isUserMessage false when type is ai', () {
      // Arrange
      final message = ChatMessage(
        id: 'msg_ai',
        content: 'Risposta AI',
        type: MessageType.ai,
        timestamp: timestamp,
      );

      // Act
      final isUser = message.isUserMessage;
      final isAi = message.isAiMessage;

      // Assert
      expect(isAi, isTrue);
      expect(isUser, isFalse);
    });
  });
}