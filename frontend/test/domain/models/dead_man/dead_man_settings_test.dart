import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/dead_man/dead_man_settings.dart';

void main() {
  group('DeadManSettings', () {
    test('dovrebbe inizializzarsi con i valori di default corretti', () {
      const settings = DeadManSettings();

      expect(settings.isActive, false);
      expect(settings.firstInactivityTimer, 5);
      expect(settings.secondInactivityTimer, 2);
      expect(settings.messageSubject, 'Emergenza: Mancato Check-in');
      expect(settings.messageBody, 'Non ho confermato il mio stato di sicurezza sull\'app. Per favore controlla la mia ultima posizione.');
    });

    test('dovrebbe inizializzarsi con i valori personalizzati', () {
      const settings = DeadManSettings(
        isActive: true,
        firstInactivityTimer: 60,
        secondInactivityTimer: 15,
        messageSubject: 'Aiuto',
        messageBody: 'Sono in pericolo',
      );

      expect(settings.isActive, true);
      expect(settings.firstInactivityTimer, 60);
      expect(settings.secondInactivityTimer, 15);
      expect(settings.messageSubject, 'Aiuto');
      expect(settings.messageBody, 'Sono in pericolo');
    });

    test('copyWith dovrebbe aggiornare solo i campi specificati', () {
      const original = DeadManSettings();

      final updated = original.copyWith(
        isActive: true,
        firstInactivityTimer: 30,
      );

      expect(updated.isActive, true);
      expect(updated.firstInactivityTimer, 30);
      // I campi non specificati devono rimanere uguali all'originale
      expect(updated.secondInactivityTimer, original.secondInactivityTimer);
      expect(updated.messageSubject, original.messageSubject);
      expect(updated.messageBody, original.messageBody);
    });

    test('copyWith senza parametri dovrebbe mantenere gli stessi valori', () {
      const original = DeadManSettings(
        isActive: true,
        firstInactivityTimer: 45,
      );

      final copy = original.copyWith();

      expect(copy.isActive, original.isActive);
      expect(copy.firstInactivityTimer, original.firstInactivityTimer);
      expect(copy.secondInactivityTimer, original.secondInactivityTimer);
      expect(copy.messageSubject, original.messageSubject);
      expect(copy.messageBody, original.messageBody);
    });
  });
}