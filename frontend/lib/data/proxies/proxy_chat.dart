import '../../domain/models/chatbot/chat.dart';
import '../../domain/models/chatbot/local_chat.dart';
import '../../domain/models/chatbot/chat_message.dart';
import '../repositories/chatbot_repository.dart';

/// Implementazione Proxy dell'interfaccia [Chat].
/// Conserva in memoria solo i metadati (anteprima). Scarica i messaggi
/// pesanti dal server solo quando viene esplicitamente richiesto tramite [load].
class ProxyChat implements Chat {
  final String _id;
  String _title;
  final DateTime _creationDate;
  DateTime _updateDate;

  // Il "Real Subject" (L'oggetto reale nascosto nel proxy)
  LocalChat? _localChat;

  // Riferimento al repository per poter andare su rete a prendere i dati
  final ChatbotRepository _repository;

  ProxyChat({
    required String id,
    required String title,
    required DateTime creationDate,
    required DateTime updateDate,
    required ChatbotRepository repository,
  })  : _id = id,
        _title = title,
        _creationDate = creationDate,
        _updateDate = updateDate,
        _repository = repository;

  @override
  String get id => _id;

  // Se l'oggetto reale esiste, deleghiamo a lui. Altrimenti usiamo la cache locale.
  @override
  String get title => _localChat?.title ?? _title;

  @override
  set title(String newTitle) {
    _title = newTitle;
    _localChat?.title = newTitle; // Propaga la modifica
  }

  @override
  DateTime get creationDate => _creationDate;

  @override
  DateTime get updateDate => _localChat?.updateDate ?? _updateDate;

  @override
  List<ChatMessage> get messages {
    // Se la chat non è ancora stata caricata, restituiamo vuoto.
    // L'UI sa che deve chiamare load() prima di disegnare i messaggi.
    return _localChat?.messages ?? [];
  }

  @override
  void addMessage(ChatMessage message) {
    // Delega l'aggiunta fisica all'oggetto reale
    _localChat?.addMessage(message);
  }

  /// Scarica l'intera cronologia dal database AWS DynamoDB solo se non è già presente.
  Future<void> load() async {
    if (_localChat == null) {
      _localChat = await _repository.getChatById(_id) as LocalChat;

      _title = _localChat!.title;
      _updateDate = _localChat!.updateDate;
    }
  }
}