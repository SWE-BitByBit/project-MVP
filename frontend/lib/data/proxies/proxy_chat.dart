import '../../domain/models/chatbot/chat.dart';
import '../../domain/models/chatbot/local_chat.dart';
import '../../domain/models/chatbot/chat_message.dart';
import '../repositories/chatbot_repository.dart';

/// Implementa il pattern Virtual Proxy per le sessioni di Chat.
/// Permette di mostrare le informazioni di base di una chat (titolo, data)
/// rimandando il download dei messaggi pesanti solo a quando l'utente la apre.
class ProxyChat implements Chat {
  final String _id;
  String _title;
  final DateTime _creationDate;
  DateTime _lastModified;

  /// Il riferimento al repository per scaricare i dati reali
  final ChatbotRepository _repository;

  /// La chat reale contenente i messaggi (inizialmente null)
  LocalChat? _localChat;

  ProxyChat({
    required String id,
    required String title,
    required DateTime creationDate,
    required DateTime lastModified,
    required ChatbotRepository repository,
  }) : _id = id,
       _title = title,
       _creationDate = creationDate,
       _lastModified = lastModified,
       _repository = repository;

  /// Metodo chiave del Proxy: scarica i messaggi completi solo quando richiesto.
  Future<void> load() async {
    if (_localChat == null) {
      // Usa il repository per fare la chiamata di rete e ottenere la chat completa
      final chatComplete = await _repository.getChatById(_id);

      // Salviamo l'istanza reale nella variabile
      _localChat = chatComplete as LocalChat;

      // Sincronizziamo eventuali discrepanze di titolo/data
      _title = _localChat!.getTitle();
      _lastModified = _localChat!.getUpdateDate();
    }
  }

  // --- Metodi delegati ---
  // Se la localChat è caricata, usa i suoi dati, altrimenti usa quelli base del Proxy.

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
    if (_localChat == null) {
      // Se si chiedono i messaggi prima di fare load(), si restituisce lista vuota
      // oppure si potrebbe lanciare un'eccezione, a seconda delle vostre logiche.
      return [];
    }
    return _localChat!.getMessages();
  }

  @override
  void addMessage(ChatMessage message) {
    // Aggiunge il messaggio solo se la chat è caricata
    _localChat?.addMessage(message);
    _lastModified = DateTime.now();
  }

  @override
  void setTitle(String title) {
    _title = title;
    _localChat?.setTitle(title);
    _lastModified = DateTime.now();
  }
}
