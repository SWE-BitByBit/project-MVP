import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/trusted_contact.dart';

import '../../../../testing/mocks/mock_trusted_contact_repository.dart';

void main() {
  late TrustedContactViewModel viewModel;
  late MockTrustedContactRepository mockRepository;

  setUp(() {
    mockRepository = MockTrustedContactRepository();
    viewModel = TrustedContactViewModel(mockRepository);
  });

  group('TrustedContactViewModel - Stato Iniziale', () {
    test('Lo stato iniziale deve essere pulito, senza contatti né errori', () {
      expect(viewModel.contacts, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });
  });

  group('TrustedContactViewModel - Caricamento Contatti', () {
    test('updateContact deve invocare il repository e ricaricare la lista', () async {
      // Arrange
      final contactModificato = TrustedContact(
        id: 'c-1',
        name: 'Mario Rossi Aggiornato',
        email: 'mario.agg@email.com',
        phoneNumber: '000',
      );
      mockRepository.mockedUpdatedContact = contactModificato;
      mockRepository.mockedContactsToReturn = [contactModificato];

      // Act
      await viewModel.updateContact(
        id: 'c-1',
        name: 'Mario Rossi Aggiornato',
        email: 'mario.agg@email.com',
        phoneNumber: '000',
      );

      // Assert
      expect(viewModel.contacts.first.getName(), 'Mario Rossi Aggiornato');
      expect(viewModel.isLoading, isFalse);
    });

    test('loadContacts carica correttamente la lista dei contatti', () async {
      // Arrange
      mockRepository.mockedContactsToReturn = [
        TrustedContact(
          id: 'c-1',
          name: 'Mario Rossi',
          email: 'mario@email.com',
          phoneNumber: '+39 333 0000001',
        ),
        TrustedContact(
          id: 'c-2',
          name: 'Laura Bianchi',
          email: 'laura@email.com',
          phoneNumber: '+39 333 0000002',
        ),
      ];

      // Act
      await viewModel.loadContacts();

      // Assert
      expect(viewModel.contacts.length, 2);
      expect(viewModel.contacts.first.getId(), 'c-1');
      expect(viewModel.contacts.first.getName(), 'Mario Rossi');
      expect(viewModel.error, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('loadContacts imposta un messaggio di errore in caso di fallimento', () async {
      // Arrange
      mockRepository.shouldThrowError = true;

      // Act
      await viewModel.loadContacts();

      // Assert
      expect(viewModel.contacts, isEmpty);
      expect(viewModel.error, contains('Errore nel caricamento dei contatti'));
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('TrustedContactViewModel - Creazione Contatto', () {
    test('createContact aggiunge un nuovo contatto e ricarica la lista', () async {
      // Arrange: il mock restituirà prima una lista vuota, poi con il nuovo contatto
      final newContact = TrustedContact(
        id: 'c-new',
        name: 'Giulia Verdi',
        email: 'giulia@email.com',
        phoneNumber: '+39 333 9999999',
      );
      mockRepository.mockedCreatedContact = newContact;
      // Dopo createContact, loadContacts viene chiamata internamente:
      // populiamo la lista che il mock restituirà alla seconda chiamata.
      mockRepository.mockedContactsToReturn = [newContact];

      // Act
      await viewModel.createContact(
        name: 'Giulia Verdi',
        email: 'giulia@email.com',
        phoneNumber: '+39 333 9999999',
      );

      // Assert
      expect(viewModel.contacts.length, 1);
      expect(viewModel.contacts.first.getName(), 'Giulia Verdi');
      expect(viewModel.error, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('createContact imposta un messaggio di errore in caso di fallimento', () async {
      // Arrange
      mockRepository.shouldThrowError = true;

      // Act
      await viewModel.createContact(
        name: 'Contatto Fantasma',
        email: 'err@err.com',
        phoneNumber: '+39 000 0000000',
      );

      // Assert
      expect(viewModel.contacts, isEmpty);
      expect(viewModel.error, contains('Impossibile creare il contatto'));
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('TrustedContactViewModel - Eliminazione Contatto', () {
    test('deleteContact rimuove il contatto dalla lista locale in caso di successo', () async {
      // Arrange: partiamo con due contatti già caricati
      mockRepository.mockedContactsToReturn = [
        TrustedContact(
          id: 'c-1',
          name: 'Da eliminare',
          email: 'a@a.com',
          phoneNumber: '0001',
        ),
        TrustedContact(
          id: 'c-2',
          name: 'Da mantenere',
          email: 'b@b.com',
          phoneNumber: '0002',
        ),
      ];
      await viewModel.loadContacts();
      expect(viewModel.contacts.length, 2);

      // Act
      await viewModel.deleteContact('c-1');

      // Assert: c-1 rimosso, c-2 rimane
      expect(viewModel.contacts.length, 1);
      expect(viewModel.contacts.first.getId(), 'c-2');
      expect(viewModel.error, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('deleteContact imposta un messaggio di errore in caso di fallimento', () async {
      // Arrange: un contatto già in lista
      mockRepository.mockedContactsToReturn = [
        TrustedContact(
          id: 'c-1',
          name: 'Stabile',
          email: 'a@a.com',
          phoneNumber: '0001',
        ),
      ];
      await viewModel.loadContacts();

      // Impostiamo l'errore solo per la delete
      mockRepository.shouldThrowError = true;

      // Act
      await viewModel.deleteContact('c-1');

      // Assert: la lista rimane invariata, appare l'errore
      expect(viewModel.contacts.length, 1);
      expect(viewModel.error, contains('Impossibile eliminare il contatto'));
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('TrustedContactViewModel - Gestione Errori', () {
    test('clearError azzera il messaggio di errore e notifica i listener', () async {
      // Arrange: forziamo un errore
      mockRepository.shouldThrowError = true;
      await viewModel.loadContacts();
      expect(viewModel.error, isNotNull);

      // Monitoriamo le notifiche
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      // Act
      viewModel.clearError();

      // Assert
      expect(viewModel.error, isNull);
      expect(notifyCount, 1);
    });
  });
}
