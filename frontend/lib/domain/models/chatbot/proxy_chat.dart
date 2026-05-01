import 'chat.dart';
import 'chat_message.dart';
import 'local_chat.dart';
import '../../../data/repositories/chatbot_repository.dart';

/// Implementazione del Proxy Pattern per la Chat.
/// Permette di avere un oggetto "leggero" nella cronologia che carica i messaggi
/// (trasformandosi in LocalChat) solo quando necessario.
class ProxyChat implements Chat {
  final String _id;
  String _title;
  final DateTime _creationDate;
  DateTime _lastModified;
  
  // Riferimento al repository per il caricamento pigro
  final ChatbotRepository _repository;
  
  // L'oggetto reale caricato in memoria
  LocalChat? _localChat;

  ProxyChat({
    required String id,
    required String title,
    required DateTime creationDate,
    required ChatbotRepository repository,
  }) : _id = id,
       _title = title,
       _creationDate = creationDate,
       _lastModified = creationDate,
       _repository = repository;

  /// Carica i dati completi della chat dal repository.
  Future<void> load() async {
    if (_localChat != null) return;
    
    final fullChat = await _repository.getChatById(_id);
    if (fullChat is LocalChat) {
      _localChat = fullChat;
    } else {
      // Se per qualche motivo getChatById non restituisce un LocalChat, 
      // dovremmo gestirlo, ma per ora assumiamo che lo faccia.
    }
  }

  bool isLoaded() => _localChat != null;

  @override
  String getId() => _id;

  @override
  String getTitle() => _localChat?.getTitle() ?? _title;

  @override
  DateTime getCreationDate() => _creationDate;

  @override
  DateTime getUpdateDate() => _localChat?.getUpdateDate() ?? _lastModified;

  @override
  List<ChatMessage> getMessages() {
    return _localChat?.getMessages() ?? [];
  }

  @override
  void addMessage(ChatMessage message) {
    // Se aggiungiamo un messaggio a un proxy non caricato, 
    // tecnicamente dovremmo caricarlo prima o creare una LocalChat al volo.
    _localChat ??= LocalChat(
      id: _id,
      title: _title,
      creationDate: _creationDate,
      messages: [],
    );
    _localChat!.addMessage(message);
    _lastModified = DateTime.now();
  }

  @override
  void setTitle(String title) {
    _title = title;
    _localChat?.setTitle(title);
    _lastModified = DateTime.now();
  }
}
