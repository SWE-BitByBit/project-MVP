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
      // Supportiamo sia 'id' che 'message_id' (stile backend)
      final String id = (msgJson['id'] ?? msgJson['message_id'] ?? '') as String;
      // Supportiamo sia 'content' che 'text' (stile backend)
      final String content =
          (msgJson['content'] ?? msgJson['text'] ?? '') as String;
      // Supportiamo sia 'type' che 'sender' (stile backend)
      final String rawType = (msgJson['type'] ?? msgJson['sender'] ?? 'USER')
          .toString()
          .toUpperCase();
      final type = rawType == 'AI' ? MessageType.ai : MessageType.user;
      // Supportiamo sia 'timestamp' che 'created_at' (stile backend)
      final String rawDate =
          (msgJson['timestamp'] ?? msgJson['created_at'] ?? DateTime.now()
              .toIso8601String()) as String;

      return ChatMessage(
        id: id,
        content: content,
        type: type,
        timestamp: DateTime.parse(rawDate),
      );
    }).toList();

    // 3. Ritorniamo la chat completa
    // Supportiamo sia 'id' che 'chat_id'
    final String chatId = (json['id'] ?? json['chat_id'] ?? '') as String;
    // Supportiamo sia 'creationDate' che 'created_at'
    final String rawCreationDate =
        (json['creationDate'] ?? json['created_at'] ?? DateTime.now()
            .toIso8601String()) as String;

    return LocalChat(
      id: chatId,
      title: (json['title'] ?? 'Senza Titolo') as String,
      creationDate: DateTime.parse(rawCreationDate),
      messages: parsedMessages,
    );
  }

  /// Converte un oggetto [Chat] in un formato JSON per il Backend.
  static Map<String, dynamic> toJson(Chat chat) {
    // 1. Convertiamo tutti i ChatMessage in mappe JSON
    final List<Map<String, dynamic>> messagesJson = chat.getMessages().map((
      msg,
    ) {
      return {
        'id': msg.id,
        'content': msg.content,
        'type': msg.type == MessageType.user ? 'USER' : 'AI',
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
