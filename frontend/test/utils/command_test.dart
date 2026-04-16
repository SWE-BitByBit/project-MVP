import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/utils/command.dart';

void main() {
  group('Command0 Unit Test', () {
    test('Stato iniziale deve essere non in esecuzione e senza errori', () {
      final command = Command0(() async => true);
      expect(command.isExecuting, isFalse);
      expect(command.errorMessage, isNull);
    });

    test('L\'esecuzione deve aggiornare isExecuting correttamente', () async {
      bool actionCalled = false;
      final command = Command0(() async {
        actionCalled = true;
        await Future.delayed(const Duration(milliseconds: 50));
        return true;
      });

      final future = command.execute();
      expect(command.isExecuting, isTrue);
      
      await future;
      
      expect(actionCalled, isTrue);
      expect(command.isExecuting, isFalse);
    });

    test('Deve gestire gli errori e impostare un messaggio d\'errore', () async {
      final command = Command0(() async {
        throw Exception('Fail');
      });

      await command.execute();

      expect(command.isExecuting, isFalse);
      expect(command.errorMessage, isNotNull);
      expect(command.errorMessage, contains('errore durante il recupero dei dati'));
    });

    test('Non deve eseguire se è già in corso', () async {
      int callCount = 0;
      final command = Command0(() async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 100));
      });

      command.execute();
      await command.execute();

      expect(callCount, 1);
    });
  });
}
