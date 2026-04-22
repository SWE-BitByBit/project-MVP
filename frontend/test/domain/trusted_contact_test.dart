import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact.dart';

void main() {
  group('TrustedContact Domain Model', () {
    test('Costruttore e Getters funzionano correttamente', () {
      final contact = TrustedContact(
        id: '123',
        name: 'Mario Rossi',
        email: 'mario@email.com',
        phoneNumber: '+39 333 1122333',
      );

      expect(contact.getId(), '123');
      expect(contact.getName(), 'Mario Rossi');
      expect(contact.getEmail(), 'mario@email.com');
      expect(contact.getPhone(), '+39 333 1122333');
    });

    test('Setters aggiornano correttamente i valori', () {
      final contact = TrustedContact(
        id: '123',
        name: 'Mario Rossi',
        email: 'mario@email.com',
        phoneNumber: '+39 333 1122333',
      );

      contact.setName('Luigi Verdi');
      contact.setEmail('luigi@email.com');
      contact.setPhone('+39 345 0000000');

      expect(contact.getName(), 'Luigi Verdi');
      expect(contact.getEmail(), 'luigi@email.com');
      expect(contact.getPhone(), '+39 345 0000000');
    });
  });
}
