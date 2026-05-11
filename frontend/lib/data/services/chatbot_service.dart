import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/dtos/chat_dto.dart';

/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la funzionalità del Chatbot.
class ChatbotService {
  /// URL base dell'API Gateway per il Chatbot.
  final String baseUrl;

  /// Il client HTTP per le richieste.
  final http.Client client;

  /// Costruttore con iniezione delle dipendenze.
  /// Se [baseUrl] non viene fornita, viene letta da [dotenv].
  ChatbotService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? dotenv.env['API_BASE_URL'] ?? '',
        client = client ?? http.Client();

  Map<String, String> _headers() {
    // TODO: Recuperare il token reale dall'AuthRepository
    const String token = "";
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Recupera la lista delle anteprime delle chat.
  Future<List<Map<String, dynamic>>> fetchChatPreviews() async {
    final uri = Uri.parse('$baseUrl/chats/');
    final res = await client.get(uri, headers: _headers());

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch chat previews');
    }

    final List data = jsonDecode(res.body);

    return data.map<Map<String, dynamic>>((e) {
      final chat = ChatDTO.fromJson(e);
      return ChatDTO.toJson(chat);
    }).toList();
  }

  /// Recupera una singola chat completa tramite il suo ID.
  Future<Map<String, dynamic>> fetchChat(String chatId) async {
    final uri = Uri.parse('$baseUrl/chats/$chatId');
    final res = await client.get(uri, headers: _headers());

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch chat');
    }

    final data = jsonDecode(res.body);
    final chat = ChatDTO.fromJson(data);

    return ChatDTO.toJson(chat);
  }

  /// Richiede al server la creazione di una nuova chat.
  Future<Map<String, dynamic>> createChat() async {
    final uri = Uri.parse('$baseUrl/chats/');

    final res = await client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to create chat');
    }

    final data = jsonDecode(res.body);
    final chat = ChatDTO.fromJson(data);

    return ChatDTO.toJson(chat);
  }

  /// Richiede al server l'eliminazione di una chat.
  Future<void> deleteChat(String chatId) async {
    final uri = Uri.parse('$baseUrl/chats/$chatId');

    final res = await client.delete(uri, headers: _headers());

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Failed to delete chat');
    }
  }

  /// Invia un messaggio all'AI specificando la modalità (Mirror o Detective) in formato stringa.
  Future<Map<String, dynamic>> sendMessage(
    String chatId,
    String content,
    String mode,
  ) async {
    final uri = Uri.parse('$baseUrl/chats/$chatId/messages');

    final res = await client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({'content': content, 'mode': mode}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Failed to send message');
    }

    return jsonDecode(res.body);
  }

  /// Genera un titolo per la chat basato sul primo messaggio inviato.
  Future<String> generateChatTitle(String content) async {
    final uri = Uri.parse('$baseUrl/chats/generate-title');
    final res = await client.post(
      uri,
      headers: _headers(),
      body: jsonEncode({'content': content}),
    );

    if (res.statusCode != 200) {
      return "Nuova conversazione"; // Fallback
    }

    final data = jsonDecode(res.body);
    return data['title'] as String;
  }
}
