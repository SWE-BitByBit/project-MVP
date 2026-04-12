import 'package:flutter/material.dart';

import '../../domain/models/chatbot/chat.dart';
import '../../domain/models/chatbot/chat_enums.dart';
import '../../domain/models/chatbot/chat_message.dart';
import '../../domain/models/chatbot/chat_preview.dart';
import '../../data/repositories/chatbot_repository.dart';

/// Gestisce lo stato della UI e la logica di business per l'intera funzionalità Chatbot.
class ChatbotViewModel extends ChangeNotifier {
  final ChatbotRepository _repository;

  // --- STATO DELLA UI ---

  List<ChatPreview> _chatPreviews = [];
  Chat? _currentChat;
  ChatMode _selectedMode = ChatMode.DETECTIVE; // Modalità di default

  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS (Per permettere alla View di leggere i dati in modo sicuro) ---

  List<ChatPreview> get chatPreviews => List.unmodifiable(_chatPreviews);
  Chat? get currentChat => _currentChat;
  ChatMode get selectedMode => _selectedMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Costruttore: richiede il repository per poter comunicare con i dati.
  ChatbotViewModel(this._repository);

  // --- METODI DI BUSINESS LOGIC ---

  /// Cambia la modalità del chatbot (Specchio / Detective)
  void setMode(ChatMode mode) {
    _selectedMode = mode;
    notifyListeners();
  }

  /// Carica la cronologia delle chat (le anteprime).
  Future<void> loadChatPreviews() async {
    _setLoading(true);
    try {
      _chatPreviews = await _repository.getChatPreviews();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Errore nel caricamento della cronologia: $e";
    } finally {
      _setLoading(false);
    }
  }

  /// Crea una nuova chat vuota sul server e la imposta come chat corrente.
  Future<void> createChat() async {
    _setLoading(true);
    try {
      _currentChat = await _repository.createChat();
      // Ricarichiamo le anteprime per mostrare la nuova chat in cima alla lista
      await loadChatPreviews();
    } catch (e) {
      _errorMessage = "Impossibile creare una nuova chat: $e";
    } finally {
      _setLoading(false);
    }
  }

  /// Apre una chat specifica recuperandola tramite il suo ID.
  Future<void> openChat(String chatId) async {
    _setLoading(true);
    try {
      _currentChat = await _repository.getChatById(chatId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Errore nell'apertura della chat: $e";
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina una chat specifica.
  Future<void> deleteChat(String chatId) async {
    _setLoading(true);
    try {
      await _repository.deleteChat(chatId);

      // Se abbiamo appena eliminato la chat che stavamo guardando, la chiudiamo
      if (_currentChat?.getId() == chatId) {
        _currentChat = null;
      }

      await loadChatPreviews(); // Aggiorna la lista
    } catch (e) {
      _errorMessage = "Impossibile eliminare la chat: $e";
    } finally {
      _setLoading(false);
    }
  }

  /// Invia un messaggio dall'utente e attende la risposta dell'AI.
  Future<void> sendChatMessage(String content) async {
    // Sicurezze: il testo non deve essere vuoto e deve esserci una chat aperta
    if (content.trim().isEmpty) return;
    if (_currentChat == null) {
      _errorMessage = "Nessuna chat attiva.";
      notifyListeners();
      return;
    }

    // 1. Creiamo e aggiungiamo istantaneamente il messaggio dell'utente alla UI
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporaneo locale
      content: content.trim(),
      type: MessageType.USER,
      timestamp: DateTime.now(),
    );
    _currentChat!.addMessage(userMessage);

    // Mostriamo subito il messaggio dell'utente e avviamo il caricamento per l'AI
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 2. Chiamiamo il repository per inviare il messaggio ad AWS
      final response = await _repository.sendMessage(
        _currentChat!,
        content.trim(),
        _selectedMode,
      );

      // 3. Aggiungiamo la risposta dell'AI alla chat
      _currentChat!.addMessage(response.getResponse());

      // 4. Se l'AI ha suggerito un nuovo titolo (es. al primo messaggio), lo aggiorniamo
      if (response.getUpdatedTitle() != null) {
        _currentChat!.setTitle(response.getUpdatedTitle()!);
        await loadChatPreviews(); // Aggiorna la lista nel menu laterale
      }
    } catch (e) {
      _errorMessage = "Errore di connessione con l'AI. Riprova.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Helper privato per gestire lo stato di caricamento.
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}