import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/trusted_contact_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact.dart';

void main() {
  group('TrustedContactDTO', () {
    final sampleJson = {
      'id': 'c-1',
      'name': 'Mario Rossi',
      'email': 'mario@email.com',
      'phoneNumber': '+39 333 1234567',
    };

    test('fromJson crea un oggetto TrustedContact corretto', () {
      final contact = TrustedContactDTO.fromJson(sampleJson);

      expect(contact.getId(), 'c-1');
      expect(contact.getName(), 'Mario Rossi');
      expect(contact.getEmail(), 'mario@email.com');
      expect(contact.getPhone(), '+39 333 1234567');
    });

    test('toJson crea una mappa JSON corretta', () {
      final contact = TrustedContact(
        id: 'c-2',
        name: 'Laura Bianchi',
        email: 'laura@email.com',
        phoneNumber: '+39 345 9876543',
      );

      final json = TrustedContactDTO.toJson(contact);

      expect(json['id'], 'c-2');
      expect(json['name'], 'Laura Bianchi');
      expect(json['email'], 'laura@email.com');
      expect(json['phoneNumber'], '+39 345 9876543');
    });
  });
}
