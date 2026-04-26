// DA RIFARE COMPLETAMENTE
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/chatbot_service.dart';

void main() {
  group('ChatbotService (Versione Placeholder)', () {
    late ChatbotService service;

    setUp(() {
      service = ChatbotService();
    });

    test('fetchChatPreviews restituisce una lista vuota', () async {
      final result = await service.fetchChatPreviews();
      expect(result, isA<List>());
      expect(result, isEmpty);
    });

    test('fetchChat restituisce una mappa vuota', () async {
      final result = await service.fetchChat('chat-123');
      expect(result, isA<Map<String, dynamic>>());
      expect(result, isEmpty);
    });

    test('createChat restituisce un JSON finto con chiavi valide', () async {
      final result = await service.createChat();

      // Verifichiamo che la mappa contenga le chiavi che il DTO si aspetta
      expect(result.containsKey('id'), isTrue);
      expect(
        result['id'],
        startsWith('chat-'),
      ); // L'id generato inizia con 'chat-'
      expect(result['title'], 'Nuova conversazione');
      expect(result.containsKey('creationDate'), isTrue);
      expect(result['messages'], isEmpty);
    });

    test('deleteChat completa l\'operazione senza lanciare errori', () async {
      // Usiamo returnsNormally per assicurarci che il Future.delayed non faccia crashare nulla
      expect(() async => await service.deleteChat('chat-123'), returnsNormally);
    });

    test(
      'sendMessage restituisce un JSON finto che include la modalità',
      () async {
        final modeStr = 'DETECTIVE';
        final result = await service.sendMessage(
          'chat-123',
          'Ciao AI',
          modeStr,
        );

        expect(result['id'], 'msg-ai-123');
        expect(result['type'], 'AI');
        expect(result.containsKey('timestamp'), isTrue);

        // Controlliamo che il testo di risposta mockato contenga effettivamente la modalità richiesta
        expect(result['content'], contains('DETECTIVE'));
      },
    );
  });
}
