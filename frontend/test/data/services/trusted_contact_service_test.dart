import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/trusted_contact_service.dart';

void main() {
  group('TrustedContactService', () {
    late TrustedContactService service;

    setUp(() {
      service = TrustedContactService();
    });

    test('getContacts restituisce la lista predefinita (Mock-up)', () async {
      final contacts = await service.getContacts();

      expect(contacts, isNotEmpty);
      expect(contacts.length, 3);
      expect(contacts.first['name'], 'Mario Rossi');
    });

    test('addContact restituisce il contatto con id generato (Mock-up)', () async {
      final sampleData = {
        'name': 'Test User',
        'email': 'test@email.com',
        'phoneNumber': '12345',
      };

      final response = await service.addContact(sampleData);

      expect(response['id'], contains('contact-'));
      expect(response['name'], 'Test User');
    });

    test('deleteContact completa senza errori (Mock-up)', () async {
      expect(
        service.deleteContact('any-id'),
        completes,
      );
    });
  });
}
