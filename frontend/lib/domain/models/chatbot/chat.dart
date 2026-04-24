import 'chat_message.dart';

/// Interfaccia che definisce il contratto per una sessione di Chat.
/// Implementata sia da [LocalChat] (dati reali) che da [ProxyChat] (lazy loading).
abstract class Chat {
  String get id;
  String get title;
  DateTime get creationDate;
  DateTime get updateDate;

  /// Restituisce la lista dei messaggi.
  /// Nel caso del Proxy, questa lista sarà vuota finché non viene chiamata la load().
  List<ChatMessage> get messages;

  /// Aggiunge un messaggio alla chat e aggiorna l'updateDate.
  void addMessage(ChatMessage message);

  /// Setter per aggiornare il titolo (usato quando il server genera il nuovo titolo).
  set title(String newTitle);
}