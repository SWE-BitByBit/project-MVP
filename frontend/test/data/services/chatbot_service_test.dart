import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/chatbot_service.dart';

void main() {
  group('ChatbotService Tests', () {
    late ChatbotService service;

    setUp(() {
      // Non è più necessario inizializzare dotenv se passiamo baseUrl esplicitamente
    });

    test('fetchChatPreviews restituisce una lista di mappe in caso di successo',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode([
              {
                'id': 'chat-1',
                'title': 'Test Chat',
                'created_at': DateTime.now().toIso8601String(),
                'messages': []
              }
            ]),
            200);
      });

      service = ChatbotService(
        baseUrl: 'https://api.example.com',
        client: mockClient,
      );

      final result = await service.fetchChatPreviews();
      expect(result, isNotEmpty);
      expect(result[0]['id'], 'chat-1');
    });

    test('fetchChat restituisce i dati della chat corretta', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'id': 'chat-123',
              'title': 'Specific Chat',
              'created_at': DateTime.now().toIso8601String(),
              'messages': []
            }),
            200);
      });

      service = ChatbotService(
        baseUrl: 'https://api.example.com',
        client: mockClient,
      );

      final result = await service.fetchChat('chat-123');
      expect(result['id'], 'chat-123');
      expect(result['title'], 'Specific Chat');
    });

    test('createChat crea una nuova chat con successo', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'id': 'new-chat-id',
              'title': 'Nuova conversazione',
              'created_at': DateTime.now().toIso8601String(),
              'messages': []
            }),
            201);
      });

      service = ChatbotService(
        baseUrl: 'https://api.example.com',
        client: mockClient,
      );

      final result = await service.createChat();
      expect(result['id'], 'new-chat-id');
      expect(result['title'], 'Nuova conversazione');
    });

    test('deleteChat completa senza errori', () async {
      final mockClient = MockClient((request) async {
        return http.Response('', 204);
      });

      service = ChatbotService(
        baseUrl: 'https://api.example.com',
        client: mockClient,
      );

      expect(service.deleteChat('chat-123'), completes);
    });

    test('sendMessage restituisce la risposta dell\'AI', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'id': 'msg-1',
              'content': 'Risposta AI in modalità DETECTIVE',
              'type': 'AI',
              'timestamp': DateTime.now().toIso8601String()
            }),
            200);
      });

      service = ChatbotService(
        baseUrl: 'https://api.example.com',
        client: mockClient,
      );

      final result = await service.sendMessage('chat-123', 'Ciao', 'DETECTIVE');
      expect(result['content'], contains('DETECTIVE'));
    });
  });
}
