import '../../domain/models/chatbot/local_chat.dart';
import '../../domain/models/chatbot/chat.dart';
import '../../domain/models/chatbot/chat_message.dart';
import '../../domain/models/chatbot/chat_enums.dart';

/// Oggetto di trasferimento dati per la serializzazione delle Chat.
/// Mappa in modo sicuro i dati JSON del backend verso il Dominio e viceversa.
class ChatDTO {
  ChatDTO._();

  /// Converte un JSON in un oggetto di Dominio [LocalChat].
  static Chat fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawMessages = json['messages'] ?? [];

    final List<ChatMessage> parsedMessages = rawMessages.map((msgJson) {
      return ChatMessage(
        id: msgJson['messageId']?.toString() ?? '',
        content: msgJson['content']?.toString() ?? '',

        type: (msgJson['type']?.toString().toUpperCase() == 'USER')
            ? MessageType.user
            : MessageType.ai,
        timestamp: DateTime.tryParse(msgJson['timestamp']?.toString() ?? '') ?? DateTime.now(),
      );
    }).toList();


    final creationStr = json['creationDate']?.toString();
    final updateStr = json['updateDate']?.toString();

    final creationDate = DateTime.tryParse(creationStr ?? '') ?? DateTime.now();
    final updateDate = DateTime.tryParse(updateStr ?? '') ?? creationDate;

    return LocalChat(
      id: json['chatId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Nuova conversazione',
      creationDate: creationDate,
      updateDate: updateDate,
      messages: parsedMessages,
    );
  }

  /// Converte un oggetto [Chat] in un formato JSON per il Backend.
  static Map<String, dynamic> toJson(Chat chat) {
    final List<Map<String, dynamic>> messagesJson = chat.messages.map((msg) {
      return {
        'messageId': msg.id,
        'content': msg.content,
        'type': msg.type == MessageType.user ? 'USER' : 'AI',
        'timestamp': msg.timestamp.toIso8601String(),
      };
    }).toList();

    return {
      'chatId': chat.id,
      'title': chat.title,
      'creationDate': chat.creationDate.toIso8601String(),
      'updateDate': chat.updateDate.toIso8601String(),
      'messages': messagesJson,
    };
  }
}