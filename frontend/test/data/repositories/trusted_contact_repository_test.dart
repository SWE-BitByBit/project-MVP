import 'package:flutter_test/flutter_test.dart';

import 'package:mvp_app_protegge_e_trasforma/data/repositories/trusted_contact_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/trusted_contact.dart';

import '../../../testing/mocks/mock_trusted_contact_service.dart';

void main() {
  group('TrustedContactRepository', () {
    late MockTrustedContactService mockService;
    late TrustedContactRepository repository;

    setUp(() {
      mockService = MockTrustedContactService();
      repository = TrustedContactRepository(mockService);
    });

    test('getContacts mappa correttamente il JSON in oggetti TrustedContact', () async {
      // Arrange
      mockService.mockedContactsJson = [
        {
          'id': 'c-1',
          'name': 'Mario Rossi',
          'email': 'mario@email.com',
          'phoneNumber': '+39 333 0000001',
        },
        {
          'id': 'c-2',
          'name': 'Laura Bianchi',
          'email': 'laura@email.com',
          'phoneNumber': '+39 333 0000002',
        },
      ];

      // Act
      final contacts = await repository.getContacts();

      // Assert
      expect(contacts.length, 2);
      expect(contacts.first.getId(), 'c-1');
      expect(contacts.first.getName(), 'Mario Rossi');
      expect(contacts.first.getEmail(), 'mario@email.com');
      expect(contacts.first.getPhone(), '+39 333 0000001');
    });

    test('createContact invia i dati e mappa correttamente la risposta', () async {
      // Arrange: prepariamo la risposta del Service con l'id assegnato dal backend
      mockService.mockedAddedContactJson = {
        'id': 'c-backend-99',
        'name': 'Giulia Verdi',
        'email': 'giulia@email.com',
        'phoneNumber': '+39 399 9999999',
      };

      // Costruiamo il contatto di dominio da passare al repository
      final contactDaSalvare = TrustedContact(
        id: '',
        name: 'Giulia Verdi',
        email: 'giulia@email.com',
        phoneNumber: '+39 399 9999999',
      );

      // Act
      final saved = await repository.createContact(contactDaSalvare);

      // Assert: verifichiamo che il Repository abbia usato l'id restituito dal backend
      expect(saved.getId(), 'c-backend-99');
      expect(saved.getName(), 'Giulia Verdi');
    });

    test('updateContact invia i dati modificati e mappa la risposta', () async {
      // Arrange
      mockService.mockedUpdatedContactJson = {
        'id': 'c-1',
        'name': 'Nome Modificato',
        'email': 'mod@email.com',
        'phoneNumber': '111',
      };
      final updateData = TrustedContact(id: 'c-1', name: 'Nome Modificato', email: 'mod@email.com', phoneNumber: '111');

      // Act
      final updated = await repository.updateContact(updateData);

      // Assert
      expect(updated.getName(), 'Nome Modificato');
    });

    test('deleteContact completa senza eccezioni in caso di successo', () async {
      await expectLater(
        repository.deleteContact('c-1'),
        completes,
      );
    });

    test('Se il Service lancia un\'eccezione, il Repository la lascia passare al ViewModel', () async {
      mockService.shouldThrowError = true;

      expect(() => repository.getContacts(), throwsException);
      expect(() => repository.deleteContact('c-1'), throwsException);
    });
  });
}
