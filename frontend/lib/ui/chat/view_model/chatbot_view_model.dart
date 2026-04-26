import 'package:flutter/foundation.dart';
import 'package:command_it/command_it.dart';

import '../../../domain/models/chatbot/chat.dart';
import '../../../data/proxies/proxy_chat.dart';
import '../../../domain/models/chatbot/chat_enums.dart';
import '../../../domain/models/chatbot/chat_message.dart';
import '../../../data/repositories/chatbot_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../domain/models/chatbot/local_chat.dart';

/// ViewModel che gestisce lo stato e la logica di presentazione del Chatbot.
class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository _repository;
  final AuthRepository _authRepository;

  // --- STATO DELLA UI ---

  List<Chat> get chats => _repository.cachedChats;

  Chat? _currentChat;
  Chat? get currentChat => _currentChat;

  ChatMode _mode = ChatMode.mirror;
  ChatMode get mode => _mode;

  final ValueNotifier<String?> asyncError = ValueNotifier(null);

  // --- COMANDI REATTIVI ---

  late final Command<void, void> loadChatPreviews;
  late final Command<void, void> createChat;
  late final Command<String, void> openChat;
  late final Command<String, void> deleteChat;
  late final Command<({Chat chat, String content, ChatMode mode}), void> sendMessage;

  /// Costruttore: inizializza il ViewModel e configura le dipendenze.
  ChatbotViewModel(
      this._repository, {
        required AuthRepository authRepository,
      }) : _authRepository = authRepository {

    // Inizializzazione dei comandi
    loadChatPreviews = Command.createAsyncNoParam<void>(
      _loadChatPreviews,
      initialValue: null,
    );

    createChat = Command.createAsyncNoParam<void>(
      _createChat,
      initialValue: null,
    );

    openChat = Command.createAsync<String, void>(
      _openChat,
      initialValue: null,
    );

    deleteChat = Command.createAsync<String, void>(
      _deleteChat,
      initialValue: null,
    );

    sendMessage = Command.createAsync<({Chat chat, String content, ChatMode mode}), void>(
      _sendMessage,
      initialValue: null,
    );

    // Caricamento automatico all'avvio
    loadChatPreviews.run();
  }

  // --- LOGICA DI SINCRONIZZAZIONE LOCALE ---

  void setMode(ChatMode newMode) {
    if (_mode != newMode) {
      _mode = newMode;
      notifyListeners();
    }
  }

  // --- IMPLEMENTAZIONE DEI COMANDI ---

  Future<void> _loadChatPreviews() async {
    final user = _authRepository.getCurrentUser();

    if (user == null) {
      debugPrint("[*] Utente non loggato: salto la chiamata /chats");
      return;
    }
    // 1. Scarichiamo i dati
    await _repository.getChatPreviews();

    // 2. Se non c'è NESSUNA chat nel database
    if (chats.isEmpty) {
      if (_currentChat == null) {
        _startNewVirtualChat();
      }
      notifyListeners();
      return;
    }

    final savedId = _repository.lastViewedChatId;

    if (savedId != null && chats.any((c) => c.id == savedId)) {

      _openChat(savedId);
    } else {
      _currentChat = chats.first;
      _repository.lastViewedChatId = _currentChat?.id;
    }

    notifyListeners();
  }

  Future<void> _createChat() async {
    _startNewVirtualChat();
    notifyListeners();
  }

  Future<void> _deleteChat(String chatId) async {
    // 1. Memorizziamo SE stiamo cancellando proprio la chat che stiamo guardando
    final wasCurrentChat = _currentChat?.id == chatId;

    // 2. FIRE AND FORGET: Diciamo al repo di cancellare.
    // IMPORTANTE: Anche se è un Future, la prima riga nel repo fa "_cachedChats.removeAt()",
    // quindi la rimozione dalla lista 'chats' avviene in modo ISTANTANEO e sincrono!
    final deleteFuture = _repository.deleteChat(chatId);

    // 3. ORA sistemiamo lo schermo. La lista 'chats' è già aggiornata
    // e NON contiene più la chat che abbiamo appena "sparato".
    if (wasCurrentChat) {
      if (chats.isNotEmpty) {
        _currentChat = chats.first; // C'è ancora qualcosa? Apriamo la prima disponibile.
      } else {
        _startNewVirtualChat(); // Era l'ultima? Creiamo subito la bozza vuota!
      }
    }

    // 4. Diciamo alla UI di ridisegnarsi con la nuova situazione
    notifyListeners();

    // 5. Gestione errori in background (Il Rollback)
    deleteFuture.catchError((e) {
      asyncError.value = "Impossibile eliminare la chat.";
      // Se fallisce, il repo ha già reinserito la chat vecchia nella sua lista.
      // Chiamiamo notifyListeners per farla "riapparire" magicamente a schermo.
      notifyListeners();
    });
  }

  Future<void> _openChat(String chatId) async {
    print('ID CERCATO: $chatId');
    final index = chats.indexWhere((c) => c.id == chatId);

    if (index == -1) {
      print("Vaffanculo");
      return;
    }

    final chat = chats[index];

    if (chat is ProxyChat) {
      await chat.load();
    }

    _currentChat = chat;
    _repository.lastViewedChatId = chatId;
    notifyListeners();
  }

  Future<void> _sendMessage(({Chat chat, String content, ChatMode mode}) args) async {
    Chat activeChat = args.chat;
    String userContent = args.content.trim();

    final optimisticMsg = ChatMessage(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      content: userContent,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    activeChat.addMessage(optimisticMsg);
    notifyListeners();

    try {
      if (activeChat is LocalChat && activeChat.id.startsWith('virtual_')) {
        final realChat = await _repository.createChat();

        realChat.addMessage(optimisticMsg);

        activeChat = realChat;
        _currentChat = realChat;

        await _repository.getChatPreviews();
      }

      final response = await _repository.sendMessage(
          activeChat,
          userContent,
          args.mode
      );

      activeChat.addMessage(response.response);

      if (response.updatedTitle != null) {
        activeChat.title = response.updatedTitle!;
      }

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void _startNewVirtualChat() {
    _currentChat = LocalChat(
      id: 'virtual_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Nuova conversazione',
      creationDate: DateTime.now(),
      updateDate: DateTime.now(),
      messages: [],
    );
  }

  @override
  void dispose() {
    loadChatPreviews.dispose();
    createChat.dispose();
    openChat.dispose();
    deleteChat.dispose();
    sendMessage.dispose();
    super.dispose();
  }
}
