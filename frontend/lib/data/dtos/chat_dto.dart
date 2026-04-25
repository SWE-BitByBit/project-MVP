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
        id: msgJson['message_id']?.toString() ?? '',
        content: msgJson['text']?.toString() ?? '',

        type: (msgJson['sender']?.toString() == 'user')
            ? MessageType.user
            : MessageType.ai,
        timestamp: DateTime.tryParse(msgJson['created_at']?.toString() ?? '') ?? DateTime.now(),
      );
    }).toList();


    final creationStr = json['created_at']?.toString();
    final updateStr = json['updated_at']?.toString();

    final creationDate = DateTime.tryParse(creationStr ?? '') ?? DateTime.now();
    final updateDate = DateTime.tryParse(updateStr ?? '') ?? creationDate;

    return LocalChat(
      id: json['chat_id']?.toString() ?? '',
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
        'chat_id':chat.id,
        'message_id': msg.id,
        'text': msg.content,
        'sender': msg.type == MessageType.user ? 'user' : 'ai',
        'created_at': msg.timestamp.toIso8601String(),
      };
    }).toList();

    return {
      'title': chat.title,
      'chat_id': chat.id,
      'created_at': chat.creationDate.toIso8601String(),
      'updated_at': chat.updateDate.toIso8601String(),
      'messages': messagesJson,
    };
  }
}