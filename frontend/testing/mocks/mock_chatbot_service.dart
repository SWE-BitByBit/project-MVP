import 'package:mvp_app_protegge_e_trasforma/data/services/chatbot_service.dart';
import 'package:http/http.dart' as http;

/// Controfigura programmabile del ChatbotService.
class MockChatbotService implements ChatbotService {
  @override
  final String baseUrl = '';
  @override
  final http.Client client = http.Client();

  // --- TELECOMANDO (Variabili di controllo per i test) ---
  bool shouldThrowError = false;

  List<Map<String, dynamic>> mockedPreviewsJson = [];
  Map<String, dynamic> mockedChatJson = {};
  Map<String, dynamic> mockedMessageResponseJson = {};

  // --- IMPLEMENTAZIONE METODI DELEGATI ---

  @override
  Future<List<Map<String, dynamic>>> fetchChatPreviews() async {
    if (shouldThrowError) {
      throw Exception('Errore 500: Server non raggiungibile');
    }

    mockedChatJson = {
      "chats": [
        {
          "user_id": "user-123",
          "chat_id": "01KPTWJ5CZ9QM4VH8CSHV451ZV",
          "title": "Nuova chat",
          "created_at": "2026-04-22T15:22:27.615449+00:00",
          "updated_at": "2026-04-22T15:22:27.615449+00:00",
          "messages": [],
        },
        {
          "user_id": "user-123",
          "chat_id": "01KPX72J3Y5MFM9982J3TFTH7H",
          "title": "Voglio trovare qualcuno",
          "created_at": "2026-04-23T13:04:39.550837+00:00",
          "updated_at": "2026-04-23T13:04:39.550837+00:00",
          "messages": [],
        },
        {
          "user_id": "user-123",
          "chat_id": "01KPX795TS9806MY09P1EVZR28",
          "title": "Voglio conoscere nuove persone",
          "created_at": "2026-04-23T13:08:16.345653+00:00",
          "updated_at": "2026-04-23T13:08:16.345653+00:00",
          "messages": [],
        },
        {
          "user_id": "user-123",
          "chat_id": "01KPX7GV76KDFNY1S41REPGRPA",
          "title": "Ho bisogno di aiuto",
          "created_at": "2026-04-23T13:12:27.622336+00:00",
          "updated_at": "2026-04-23T13:12:27.622336+00:00",
          "messages": [],
        },
      ],
    };

    return mockedPreviewsJson;
  }

  @override
  Future<Map<String, dynamic>> fetchChat(String chatId) async {
    if (shouldThrowError) {
      throw Exception('Errore 404: Chat non trovata');
    }

    // Restituisce i dati finti solo se non sono stati impostati manualmente dal test
    if (mockedChatJson.isEmpty) {
      mockedChatJson = {
        "user_id": "user-123",
        "chat_id": "01KPTWJ5CZ9QM4VH8CSHV451ZV",
        "title": "Nuova chat",
        "created_at": "2026-04-22T15:22:27.615449+00:00",
        "updated_at": "2026-04-22T15:22:27.615449+00:00",
        "messages": [
          {
            "chat_id": "01KPTWJ5CZ9QM4VH8CSHV451ZV",
            "message_id": "01KPV06H6NVMXSJNV0P2PBPPM1",
            "text": "Ciao, come ti chiami?",
            "sender": "user",
            "created_at": "2026-04-22T16:26:00.789610+00:00",
          },
          {
            "chat_id": "01KPTWJ5CZ9QM4VH8CSHV451ZV",
            "message_id": "01KPV06H7X7EGV6GCN6P1VYKQH",
            "text": "Mi chiamo AI e sono il tuo assistente virtuale",
            "sender": "ai",
            "created_at": "2026-04-22T16:26:00.829470+00:00",
          },
        ],
      };
    }
    return mockedChatJson;
  }

  @override
  Future<Map<String, dynamic>> createChat() async {
    if (shouldThrowError) {
      throw Exception('Errore 500: Impossibile creare la chat');
    }

    mockedChatJson = {
      "user_id": "user-123",
      "chat_id": "01KPX8GRRJRERY8N4BJY93W83T",
      "title": "La mia nuovissima chat",
      "created_at": "2026-04-23T13:29:53.682655+00:00",
      "updated_at": "2026-04-23T13:29:53.682655+00:00",
      "messages": [],
    };
    return mockedChatJson;
  }

  @override
  Future<void> deleteChat(String chatId) async {
    if (shouldThrowError) {
      throw Exception('Errore 500: Impossibile eliminare');
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(
    String chatId,
    String content,
    String mode,
  ) async {
    if (shouldThrowError) throw Exception('Errore di rete durante l\'invio');
    mockedMessageResponseJson = {
      "message_id": "msg-ai-123",
      "text": "Questa è la mia risposta",
      "sender": "ai",
      "created_at": DateTime.now().toIso8601String(),
      "updated_title": "Titolo Aggiornato AI"
    };
    return mockedMessageResponseJson;
  }

  @override
  Future<String> generateChatTitle(String content) async {
    return "Titolo Generato Mock";
  }
}
