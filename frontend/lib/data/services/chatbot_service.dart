import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../data/dtos/chat_dto.dart';

/// Servizio responsabile della comunicazione HTTP/REST con il backend AWS
/// per la funzionalità del Chatbot.
// DA IMPLEMENTARE
class ChatbotService {
  final String baseUrl = dotenv.env['API_GATEWAY_URL'] ?? '';
  final http.Client client = http.Client();

  Map<String, String> _headers() {
    final token = "";
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
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
}
