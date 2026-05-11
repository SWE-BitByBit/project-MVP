import 'chat_message.dart';

/// Interfaccia che definisce il contratto per una sessione di Chat.
abstract class Chat {
  String get id;
  String get title;
  DateTime get creationDate;
  DateTime get updateDate;

  /// Restituisce la lista dei messaggi.
  List<ChatMessage> get messages;

  /// Aggiunge un messaggio alla chat e aggiorna l'updateDate.
  void addMessage(ChatMessage message);
  void removeMessage(String messageId);

  /// Setter per aggiornare il titolo della chat.
  set title(String newTitle);
}
