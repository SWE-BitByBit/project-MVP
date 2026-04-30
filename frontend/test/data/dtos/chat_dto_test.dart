import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/chat_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';

void main() {
  Map<String, dynamic> readFixture(String name) {
    // Gestione sicura del path a seconda di come vengono eseguiti i test (IDE vs CLI)
    final path = Directory.current.path.endsWith('test')
        ? '../testing/fixtures/chatbot/$name'
        : 'testing/fixtures/chatbot/$name';
    final file = File(path);
    return jsonDecode(file.readAsStringSync());
  }

  group('ChatDTO Tests', () {
    group('fromJson', () {
      test('dovrebbe parsare correttamente un JSON valido (Happy Path)', () {
        // Arrange
        final json = readFixture('chat_valid.json');

        // Act
        final result = ChatDTO.fromJson(json);

        // Assert
        expect(result, isA<LocalChat>());
        expect(result.id, 'chat_123');
        expect(result.title, 'Emergenza e supporto');
        expect(result.creationDate, DateTime.parse('2023-10-01T12:00:00.000Z'));
        expect(result.updateDate, DateTime.parse('2023-10-01T12:30:00.000Z'));

        expect(result.messages.length, 2);

        final firstMessage = result.messages[0];
        expect(firstMessage.id, 'msg_1');
        expect(firstMessage.content, 'Ho bisogno di aiuto');
        expect(firstMessage.type, MessageType.user);
        expect(firstMessage.timestamp, DateTime.parse('2023-10-01T12:05:00.000Z'));

        final secondMessage = result.messages[1];
        expect(secondMessage.id, 'msg_2');
        expect(secondMessage.content, 'Come posso aiutarti oggi?');
        expect(secondMessage.type, MessageType.ai);
        expect(secondMessage.timestamp, DateTime.parse('2023-10-01T12:05:05.000Z'));
      });

      test('dovrebbe fornire valori di default per campi mancanti o nulli', () {
        // Arrange
        final json = readFixture('chat_incomplete.json');

        // Act
        final result = ChatDTO.fromJson(json);

        // Assert
        expect(result.id, '');
        expect(result.title, 'Nuova conversazione');
        expect(result.messages, isEmpty);

        // Verifica che le date di default siano state generate in prossimità dell'esecuzione
        final now = DateTime.now();
        final differenceCreation = now.difference(result.creationDate).inSeconds.abs();
        final differenceUpdate = now.difference(result.updateDate).inSeconds.abs();

        expect(differenceCreation, lessThan(2)); // Tolleranza di 2 secondi
        expect(differenceUpdate, lessThan(2));
      });

      test('dovrebbe gestire formati data non validi impostandoli ai default (DateTime.now())', () {
        // Arrange
        final json = {
          'chat_id': 'chat_error',
          'created_at': 'data-invalida',
          'messages': [
            {
              'message_id': 'msg_err',
              'created_at': 'timestamp-invalido'
            }
          ]
        };

        // Act
        final result = ChatDTO.fromJson(json);

        // Assert
        final now = DateTime.now();
        expect(now.difference(result.creationDate).inSeconds.abs(), lessThan(2));
        expect(now.difference(result.updateDate).inSeconds.abs(), lessThan(2));
        expect(now.difference(result.messages.first.timestamp).inSeconds.abs(), lessThan(2));
      });
    });

    group('toJson', () {
      test('dovrebbe serializzare correttamente un oggetto Chat in JSON (Happy Path)', () {
        // Arrange
        final chat = LocalChat(
          id: 'chat_456',
          title: 'Titolo di test',
          creationDate: DateTime.utc(2023, 11, 1, 10, 0, 0),
          updateDate: DateTime.utc(2023, 11, 1, 10, 30, 0),
          messages: [
            ChatMessage(
              id: 'msg_3',
              content: 'Messaggio utente',
              type: MessageType.user,
              timestamp: DateTime.utc(2023, 11, 1, 10, 5, 0),
            ),
            ChatMessage(
              id: 'msg_4',
              content: 'Risposta AI',
              type: MessageType.ai,
              timestamp: DateTime.utc(2023, 11, 1, 10, 5, 10),
            )
          ],
        );

        // Act
        final result = ChatDTO.toJson(chat);

        // Assert
        expect(result['chat_id'], 'chat_456');
        expect(result['title'], 'Titolo di test');
        expect(result['created_at'], '2023-11-01T10:00:00.000Z');
        expect(result['updated_at'], '2023-11-01T10:30:00.000Z');

        final messagesJson = result['messages'] as List<Map<String, dynamic>>;
        expect(messagesJson.length, 2);

        expect(messagesJson[0]['chat_id'], 'chat_456');
        expect(messagesJson[0]['message_id'], 'msg_3');
        expect(messagesJson[0]['text'], 'Messaggio utente');
        expect(messagesJson[0]['sender'], 'user');
        expect(messagesJson[0]['created_at'], '2023-11-01T10:05:00.000Z');

        expect(messagesJson[1]['chat_id'], 'chat_456');
        expect(messagesJson[1]['message_id'], 'msg_4');
        expect(messagesJson[1]['text'], 'Risposta AI');
        expect(messagesJson[1]['sender'], 'ai');
        expect(messagesJson[1]['created_at'], '2023-11-01T10:05:10.000Z');
      });

      test('dovrebbe serializzare una chat senza messaggi', () {
        // Arrange
        final chat = LocalChat(
          id: 'chat_empty',
          title: 'Vuota',
          creationDate: DateTime.utc(2024, 1, 1),
          updateDate: DateTime.utc(2024, 1, 1),
          messages: [],
        );

        // Act
        final result = ChatDTO.toJson(chat);

        // Assert
        expect(result['chat_id'], 'chat_empty');
        expect(result['messages'], isEmpty);
      });
    });
  });
}