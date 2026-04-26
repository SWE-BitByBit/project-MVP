import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';

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
      expect(viewModel.loadContacts.running, isFalse);
      expect(viewModel.loadContacts.error, isNull);
    });
  });

  group('TrustedContactViewModel - Caricamento Contatti', () {
    test(
      'updateContact deve invocare il repository e ricaricare la lista',
      () async {
        // Arrange
        final contactModificato = TrustedContact(
          id: 'c-1',
          name: 'Mario Rossi Aggiornato',
          email: 'mario.agg@email.com',
          phoneNumber: '000',
        );

        mockRepository.mockedContactsToReturn = [contactModificato];

        // Act
        await viewModel.updateContact.execute(
          TrustedContact(
            id: 'c-1',
            name: 'Mario Rossi',
            email: 'mario.agg@email.com',
            phoneNumber: '000',
          ),
        );

        expect(viewModel.contacts.first.getName(), 'Mario Rossi Aggiornato');
      },
    );

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
      await viewModel.loadContacts.execute();

      // Assert
      expect(viewModel.contacts.length, 2);
      expect(viewModel.contacts.first.getId(), 'c-1');
      expect(viewModel.contacts.first.getName(), 'Mario Rossi');
      expect(viewModel.loadContacts.running, isFalse);
      expect(viewModel.loadContacts.error, isNull);
    });

    test(
      'loadContacts imposta un messaggio di errore in caso di fallimento',
      () async {
        // Arrange
        mockRepository.shouldThrowError = true;

        // Act
        await viewModel.loadContacts.execute();

        // Assert
        expect(viewModel.contacts, isEmpty);
        expect(
          viewModel.loadContacts.error.toString(),
          contains('Errore nel caricamento dei contatti'),
        );
        expect(viewModel.loadContacts.running, isFalse);
      },
    );
  });

  group('TrustedContactViewModel - Creazione Contatto', () {
    test(
      'createContact aggiunge un nuovo contatto e ricarica la lista',
      () async {
        // Arrange: il mock restituirà prima una lista vuota, poi con il nuovo contatto
        final newContact = TrustedContact(
          id: 'contact-test-new',
          name: 'Giulia Verdi',
          email: 'giulia@email.com',
          phoneNumber: '+39 333 9999999',
        );
        mockRepository.mockedCreatedContact = newContact;
        // Dopo createContact, loadContacts viene chiamata internamente:
        // populiamo la lista che il mock restituirà alla seconda chiamata.
        mockRepository.mockedContactsToReturn = [newContact];

        // Act
        await viewModel.createContact.execute(
          TrustedContact(
            id: '',
            name: 'Giulia Verdi',
            email: 'giulia@email.com',
            phoneNumber: '+39 333 9999999',
          ),
        );

        // Assert
        expect(viewModel.contacts.length, 1);
        expect(viewModel.contacts.first.getName(), 'Giulia Verdi');
        expect(viewModel.createContact.error, isNull);
        expect(viewModel.createContact.running, isFalse);
      },
    );

    test(
      'createContact imposta un messaggio di errore in caso di fallimento',
      () async {
        // Arrange
        mockRepository.shouldThrowError = true;

        // Act
        await viewModel.createContact.execute(
          TrustedContact(
            id: 'c-1',
            name: 'Contatto Fantasma',
            email: 'err@err.com',
            phoneNumber: '+39 000 0000000',
          ),
        );

        // Assert
        expect(viewModel.createContact.error, isNotNull);
        expect(
          viewModel.createContact.error.toString(),
          contains('Errore di rete simulato durante createContact'),
        );
        expect(viewModel.createContact.running, isFalse);
        expect(viewModel.createContact.completed, isFalse);
      },
    );
  });

  group('TrustedContactViewModel - Eliminazione Contatto', () {
    test(
      'deleteContact rimuove il contatto dalla lista locale in caso di successo',
      () async {
        // Arrange
        final contact1 = TrustedContact(
          id: 'c-1',
          name: 'Da eliminare',
          email: 'a@a.com',
          phoneNumber: '0001',
        );

        final contact2 = TrustedContact(
          id: 'c-2',
          name: 'Da mantenere',
          email: 'b@b.com',
          phoneNumber: '0002',
        );

        mockRepository.mockedContactsToReturn = [contact1, contact2];

        // carica i contatti iniziali
        await viewModel.loadContacts.execute();

        expect(viewModel.contacts.length, 2);

        // Act
        await viewModel.deleteContact.execute('c-1');

        // Assert

        // lista aggiornata localmente
        expect(viewModel.contacts.length, 1);
        expect(viewModel.contacts.first.getId(), 'c-2');

        // nessun errore
        expect(viewModel.deleteContact.error, isNull);

        // comando terminato
        expect(viewModel.deleteContact.running, isFalse);
        expect(viewModel.deleteContact.completed, isTrue);
      },
    );

    test(
      'deleteContact imposta un messaggio di errore in caso di fallimento',
      () async {
        // Arrange: un contatto già in lista
        mockRepository.mockedContactsToReturn = [
          TrustedContact(
            id: 'c-1',
            name: 'Stabile',
            email: 'a@a.com',
            phoneNumber: '0001',
          ),
        ];
        await viewModel.loadContacts.execute();

        // Impostiamo l'errore solo per la delete
        mockRepository.shouldThrowError = true;

        // Act
        await viewModel.deleteContact.execute('c-1');

        // Assert: la lista rimane invariata, appare l'errore
        expect(viewModel.contacts.length, 1);
        expect(viewModel.deleteContact.error, isA<Exception>());
        expect(viewModel.deleteContact.running, isFalse);
      },
    );
  });

  group('TrustedContactViewModel - Gestione Errori', () {
    test(
      'clearError azzera il messaggio di errore e notifica i listener',
      () async {
        // Arrange: forziamo un errore
        mockRepository.shouldThrowError = true;
        await viewModel.loadContacts.execute();
        expect(viewModel.loadContacts.error, isNotNull);

        // Monitoriamo le notifiche
        int notifyCount = 0;
        viewModel.addListener(() => notifyCount++);

        // Act
        viewModel.loadContacts.clearResult();

        // Assert
        expect(viewModel.loadContacts.error, isNull);
        expect(notifyCount, 1);
      },
    );
  });
}
