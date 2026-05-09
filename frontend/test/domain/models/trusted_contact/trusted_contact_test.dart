import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';

void main() {
  group('TrustedContact', () {
    const tId = '1';
    const tName = 'Mario Rossi';
    const tEmail = 'mario.rossi@example.com';
    const tPhone = '+393331234567';

    test('dovrebbe inizializzare correttamente i campi', () {
      final contact = TrustedContact(
        id: tId,
        name: tName,
        email: tEmail,
        phoneNumber: tPhone,
      );

      expect(contact.id, tId);
      expect(contact.name, tName);
      expect(contact.email, tEmail);
      expect(contact.phoneNumber, tPhone);
    });

    test('copyWith dovrebbe aggiornare solo i campi specificati', () {
      final original = TrustedContact(
        id: tId,
        name: tName,
        email: tEmail,
        phoneNumber: tPhone,
      );

      final updated = original.copyWith(
        name: 'Giuseppe Verdi',
        phoneNumber: '+393339876543',
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Giuseppe Verdi');
      expect(updated.email, original.email);
      expect(updated.phoneNumber, '+393339876543');
    });

    test('copyWith senza parametri dovrebbe restituire un nuovo oggetto con gli stessi valori', () {
      final original = TrustedContact(
        id: tId,
        name: tName,
        email: tEmail,
        phoneNumber: tPhone,
      );

      final copy = original.copyWith();

      // Non è la stessa istanza in memoria, ma i valori sono uguali
      expect(identical(original, copy), false);
      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.email, original.email);
      expect(copy.phoneNumber, original.phoneNumber);
    });
  });
}