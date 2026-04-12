import '../../domain/models/chatbot/local_chat.dart';
import '../../domain/models/chatbot/chat.dart';
import '../../domain/models/chatbot/chat_message.dart';
import '../../domain/models/chatbot/chat_enums.dart';

/// Oggetto di trasferimento dati per la serializzazione delle Chat.
/// Mappa i dati JSON del backend verso il Dominio e viceversa.
class ChatDTO {

  ChatDTO._(); // Costruttore privato: contiene solo metodi statici.

  /// Converte un JSON in un oggetto di Dominio [LocalChat].
  static Chat fromJson(Map<String, dynamic> json) {
    // 1. Estraiamo la lista dei messaggi grezza, se presente
    final List<dynamic> rawMessages = json['messages'] ?? [];

    // 2. Mappiamo ogni json-messaggio in un vero ChatMessage
    final List<ChatMessage> parsedMessages = rawMessages.map((msgJson) {
      return ChatMessage(
        id: msgJson['id'] as String,
        content: msgJson['content'] as String,
        type: msgJson['type'] == 'USER' ? MessageType.USER : MessageType.AI,
        timestamp: DateTime.parse(msgJson['timestamp'] as String),
      );
    }).toList();

    // 3. Ritorniamo la chat completa
    return LocalChat(
      id: json['id'] as String,
      title: json['title'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
      messages: parsedMessages,
    );
  }

  /// Converte un oggetto [Chat] in un formato JSON per il Backend.
  static Map<String, dynamic> toJson(Chat chat) {
    // 1. Convertiamo tutti i ChatMessage in mappe JSON
    final List<Map<String, dynamic>> messagesJson = chat.getMessages().map((msg) {
      return {
        'id': msg.id,
        'content': msg.content,
        'type': msg.type == MessageType.USER ? 'USER' : 'AI',
        'timestamp': msg.timestamp.toIso8601String(),
      };
    }).toList();

    // 2. Creiamo il JSON completo della conversazione
    return {
      'id': chat.getId(),
      'title': chat.getTitle(),
      'creationDate': chat.getCreationDate().toIso8601String(),
      'lastModified': chat.getUpdateDate().toIso8601String(),
      'messages': messagesJson,
    };
  }
}