import 'chat.dart';
import 'chat_message.dart';

/// Implementazione concreta dell'interfaccia [Chat].
/// Rappresenta una chat gestita localmente o instanziata in memoria.
class LocalChat implements Chat {
  final String _id;
  String _title;
  final DateTime _creationDate;
  DateTime _lastModified;
  final List<ChatMessage> _messages;

  LocalChat({
    required String id,
    required String title,
    required DateTime creationDate,
    required List<ChatMessage> messages,
  })  : _id = id,
        _title = title,
        _creationDate = creationDate,
        _lastModified = DateTime.now(), // Si auto-imposta al momento della creazione in RAM
        _messages = messages;

  @override
  String getId() => _id;

  @override
  String getTitle() => _title;

  @override
  DateTime getCreationDate() => _creationDate;

  @override
  DateTime getUpdateDate() => _lastModified;

  @override
  List<ChatMessage> getMessages() => List.unmodifiable(_messages);

  @override
  void addMessage(ChatMessage message) {
    _messages.add(message);
    _lastModified = DateTime.now(); // Aggiorna il timestamp di modifica
  }

  @override
  void setTitle(String title) {
    _title = title;
    _lastModified = DateTime.now(); // Aggiorna il timestamp di modifica
  }
}