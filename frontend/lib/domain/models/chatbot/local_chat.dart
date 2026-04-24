import 'chat.dart';
import 'chat_message.dart';

/// Implementazione concreta dell'interfaccia [Chat].
/// Contiene fisicamente la lista dei messaggi in RAM.
class LocalChat implements Chat {
  final String _id;
  String _title;
  final DateTime _creationDate;
  DateTime _updateDate;
  final List<ChatMessage> _messages;

  LocalChat({
    required String id,
    required String title,
    required DateTime creationDate,
    required DateTime updateDate,
    required List<ChatMessage> messages,
  })  : _id = id,
        _title = title,
        _creationDate = creationDate,
        _updateDate = updateDate,
        _messages = messages;

  @override
  String get id => _id;

  @override
  String get title => _title;

  @override
  set title(String newTitle) {
    _title = newTitle;
    _updateDate = DateTime.now();
  }

  @override
  DateTime get creationDate => _creationDate;

  @override
  DateTime get updateDate => _updateDate;

  // Restituiamo una vista non modificabile per impedire che qualcuno
  // faccia chat.messages.add() bypassando il metodo addMessage().
  @override
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  @override
  void addMessage(ChatMessage message) {
    _messages.add(message);
    _updateDate = DateTime.now();
  }
}