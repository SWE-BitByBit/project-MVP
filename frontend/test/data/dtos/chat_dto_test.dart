import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';

// Sostituisci questi import in base ai percorsi del tuo progetto
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/local_chat.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/chatbot/chat_message.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/chat_dto.dart';

void main() {
  group('ChatDTO - Data Transfer Object', () {

    final sampleDate = DateTime(2024, 5, 20, 14, 30);
    final sampleDateString = sampleDate.toIso8601String();

    test('fromJson legge correttamente i dati da un file JSON esterno', () {


      final file = File('testing_utilities/fixtures/chat_response.json');
      final jsonString = file.readAsStringSync();
      final Map<String, dynamic> jsonDalBackend = jsonDecode(jsonString);


      final chat = ChatDTO.fromJson(jsonDalBackend);

      expect(chat.getId(), 'chat-100');
      expect(chat.getTitle(), 'Indagine Omicidio');
      expect(chat.getCreationDate(), sampleDate);

      final messages = chat.getMessages();
      expect(messages.length, 2);
      expect(messages[0].id, 'msg-1');
      expect(messages[0].type, MessageType.USER);
      expect(messages[1].id, 'msg-2');
      expect(messages[1].type, MessageType.AI);
      expect(messages[1].timestamp, sampleDate);
    });

    // TEST 2: Caso limite (La lista messaggi non c'è)
    test('fromJson gestisce correttamente l\'assenza della chiave "messages"', () {
      // Arrange: Un JSON valido ma senza messaggi (es. una chat appena creata)
      final jsonSenzaMessaggi = {
        'id': 'chat-101',
        'title': 'Nuova Chat Vuota',
        'creationDate': sampleDateString,
      };

      // Act
      final chat = ChatDTO.fromJson(jsonSenzaMessaggi);

      // Assert: Grazie al tuo "?? []" nel codice, non deve crashare ma restituire lista vuota
      expect(chat.getId(), 'chat-101');
      expect(chat.getMessages(), isEmpty);
    });

    // TEST 3: Dall'App al Server (toJson)
    test('toJson converte correttamente un oggetto Chat in una Map JSON', () {
      // 1. Arrange: Creiamo un oggetto LocalChat reale
      final chatOriginale = LocalChat(
        id: 'chat-200',
        title: 'Test Serializzazione',
        creationDate: sampleDate,
        messages: [
          ChatMessage(
            id: 'msg-1',
            content: 'Invia al server',
            type: MessageType.USER,
            timestamp: sampleDate,
          )
        ],
      );

      // 2. Act: Usiamo il DTO per trasformarlo in JSON
      final jsonOutput = ChatDTO.toJson(chatOriginale);

      // 3. Assert: Controlliamo che le chiavi e i valori della Mappa siano pronti per internet
      expect(jsonOutput['id'], 'chat-200');
      expect(jsonOutput['title'], 'Test Serializzazione');
      expect(jsonOutput['creationDate'], sampleDateString);

      // Essendo LocalChat a impostare lastModified al momento della creazione, ci basta
      // assicurarci che il DTO non l'abbia perso per strada.
      expect(jsonOutput['lastModified'], isNotNull);

      // Verifichiamo la lista annidata
      expect(jsonOutput['messages'], isA<List>());
      final messagesJson = jsonOutput['messages'] as List;
      expect(messagesJson.length, 1);
      expect(messagesJson[0]['id'], 'msg-1');
      expect(messagesJson[0]['content'], 'Invia al server');
      expect(messagesJson[0]['type'], 'USER'); // L'Enum deve essere tornato Stringa
      expect(messagesJson[0]['timestamp'], sampleDateString);
    });

  });
}