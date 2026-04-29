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

  ChatbotViewModel(
      this._repository, {
        required AuthRepository authRepository,
      }) : _authRepository = authRepository {

    loadChatPreviews = Command.createAsyncNoParam<void>(_loadChatPreviews, initialValue: null);
    createChat = Command.createAsyncNoParam<void>(_createChat, initialValue: null);
    openChat = Command.createAsync<String, void>(_openChat, initialValue: null);
    deleteChat = Command.createAsync<String, void>(_deleteChat, initialValue: null);
    sendMessage = Command.createAsync<({Chat chat, String content, ChatMode mode}), void>(_sendMessage, initialValue: null);

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

    await _repository.getChatPreviews();

    if (chats.isEmpty) {
      if (_currentChat == null) {
        _startNewVirtualChat();
      }
      notifyListeners();
      return;
    }

    final savedId = _repository.lastViewedChatId;

    if (savedId != null && chats.any((c) => c.id == savedId)) {
      await _openChat(savedId);
    } else {
      _startNewVirtualChat();
    }

    notifyListeners();
  }

  Future<void> _createChat() async {
    _startNewVirtualChat();
    notifyListeners();
  }

  Future<void> _deleteChat(String chatId) async {
    final wasCurrentChat = _currentChat?.id == chatId;
    final deleteFuture = _repository.deleteChat(chatId);

    if (wasCurrentChat) {
      if (chats.isNotEmpty) {
        _currentChat = chats.first;
      } else {
        _startNewVirtualChat();
      }
    }

    notifyListeners();

    deleteFuture.catchError((e) {
      asyncError.value = "Impossibile eliminare la chat.";
      notifyListeners();
    });
  }

  Future<void> _openChat(String chatId) async {
    final index = chats.indexWhere((c) => c.id == chatId);

    if (index == -1) return;

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

        _repository.lastViewedChatId = realChat.id;
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
      // ROLLBACK: Se c'è un errore di rete, togliamo il messaggio finto dalla UI
      activeChat.messages.removeWhere((msg) => msg.id == optimisticMsg.id);
      asyncError.value = "Errore nell'invio del messaggio.";
      notifyListeners();
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