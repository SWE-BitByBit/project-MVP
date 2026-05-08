import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';
import 'package:mvp_app_protegge_e_trasforma/data/network/api_exception.dart';

import '../../../../testing/mocks/trusted_contacts/mock_trusted_contact_repository.dart';
import '../../../../testing/mocks/auth/mock_auth_repository.dart';

// Mock per l'eccezione custom necessaria per testare la validazione
class MockApiException extends Mock implements ApiException {}

void main() {
  late TrustedContactViewModel viewModel;
  late MockTrustedContactRepository mockRepository;
  late MockAuthRepository mockAuthRepository;

  final tContact = TrustedContact(
    id: '1',
    name: 'Mario Rossi',
    email: 'mario.rossi@example.com',
    phoneNumber: '+393331234567',
  );

  final tContactsList = [tContact];

  setUpAll(() {
    registerTrustedContactFallbackValue();
    Command.globalExceptionHandler = (error, stackTrace) {};
  });

  setUp(() {
    mockRepository = MockTrustedContactRepository();
    mockAuthRepository = MockAuthRepository();

    // Aggiornato per accettare il parametro named forceRefresh
    when(
          () => mockRepository.getContacts(forceRefresh: any(named: 'forceRefresh')),
    ).thenAnswer((_) async => tContactsList);
  });

  group('TrustedContactViewModel - CRUD Operations', () {
    setUp(() {
      viewModel = TrustedContactViewModel(
        mockRepository,
        authRepository: mockAuthRepository,
      );
    });

    test('createContact should call repository and refresh list', () async {
      when(
            () => mockRepository.createContact(any()),
      ).thenAnswer((_) async => tContact);
      when(
            () => mockRepository.getContacts(forceRefresh: any(named: 'forceRefresh')),
      ).thenAnswer((_) async => [...tContactsList, tContact]);

      await viewModel.createContact.runAsync(tContact);

      expect(viewModel.contacts.length, 2);
    });

    test('updateContact should call repository and refresh list', () async {
      when(
            () => mockRepository.updateContact(any()),
      ).thenAnswer((_) async => tContact);

      await viewModel.updateContact.runAsync(tContact);

      verify(() => mockRepository.updateContact(tContact)).called(1);
      // Verifica esplicita del parametro forceRefresh: false
      verify(() => mockRepository.getContacts(forceRefresh: false)).called(greaterThanOrEqualTo(1));
    });

    test(
      'deleteContact should perform optimistic update and refresh on success',
          () async {
        when(
              () => mockRepository.deleteContact(any()),
        ).thenAnswer((_) async {});

        await viewModel.deleteContact.runAsync('1');

        verify(() => mockRepository.deleteContact('1')).called(1);
        verify(() => mockRepository.getContacts(forceRefresh: false)).called(greaterThanOrEqualTo(1));
      },
    );

    test('deleteContact should rollback and force refresh list on failure', () async {
      when(
            () => mockRepository.deleteContact(any()),
      ).thenThrow(Exception('Server Error'));

      try {
        await viewModel.deleteContact.runAsync('1');
      } catch (e) {
        expect(e, isException);
      }

      expect(viewModel.deleteContact.errors.value, isNotNull);
      // Verifica del trigger di rollback esplicito
      verify(() => mockRepository.getContacts(forceRefresh: true)).called(greaterThanOrEqualTo(1));
    });
  });

  group('TrustedContactViewModel - Error Handling & Validation', () {
    test('loadContacts should set error on repository failure', () async {
      when(
            () => mockRepository.getContacts(forceRefresh: any(named: 'forceRefresh')),
      ).thenThrow(Exception('Fetch Error'));

      viewModel = TrustedContactViewModel(
        mockRepository,
        authRepository: mockAuthRepository,
      );

      await Future.delayed(Duration.zero);

      expect(viewModel.loadContacts.errors.value, isNotNull);
    });

    setUp(() {
      // Inizializza un ViewModel fresco per i test sui form
      viewModel = TrustedContactViewModel(
        mockRepository,
        authRepository: mockAuthRepository,
      );
    });

    test('handleInputError should do nothing if error is not ApiException', () {
      // Act
      viewModel.handleInputError(Exception('Generic error'));

      // Assert
      expect(viewModel.errors['name'], isEmpty);
      expect(viewModel.errors['email'], isEmpty);
      expect(viewModel.errors['phone'], isEmpty);
    });

    test('handleInputError should early return if validation errors map is empty', () {
      // Arrange
      final mockApiEx = MockApiException();
      when(() => mockApiEx.message).thenReturn(jsonEncode({
        "message": "Some generic failure",
        "errors": {}
      }));

      // Act
      viewModel.handleInputError(mockApiEx);

      // Assert
      expect(viewModel.errors['name'], isEmpty);
      expect(viewModel.errors['email'], isEmpty);
    });

    test('handleInputError should map backend validation errors to UI state correctly', () {
      // Arrange
      final mockApiEx = MockApiException();
      when(() => mockApiEx.message).thenReturn(jsonEncode({
        "message": "Unprocessable Entity",
        "errors": {
          "contact_name": ["The name field is required."],
          "contact_email": ["Invalid email format."],
          "contact_phone_number": ["Invalid phone number."]
        }
      }));

      // Act
      viewModel.handleInputError(mockApiEx);

      // Assert
      expect(viewModel.errors['name'], "Il nome inserito non è valido");
      expect(viewModel.errors['email'], "L'email inserita non è valida");
      expect(viewModel.errors['phone'], "Il numero di telefono inserito non è valido");
    });

    test('handleInputError should specifically handle "email already exists" message', () {
      // Arrange
      final mockApiEx = MockApiException();
      when(() => mockApiEx.message).thenReturn(jsonEncode({
        "message": "email already exists"
      }));

      // Act
      viewModel.handleInputError(mockApiEx);

      // Assert
      expect(viewModel.errors['email'], "L'email inserita è già associata a un contatto fidato");
    });

    test('clearInputErrors should reset all validation maps to empty strings', () {
      // Arrange: forziamo prima un errore
      final mockApiEx = MockApiException();
      when(() => mockApiEx.message).thenReturn(jsonEncode({
        "message": "email already exists"
      }));
      viewModel.handleInputError(mockApiEx);
      expect(viewModel.errors['email'], isNotEmpty); // Verifica inserimento errore

      // Act
      viewModel.clearInputErrors();

      // Assert
      expect(viewModel.errors['name'], isEmpty);
      expect(viewModel.errors['email'], isEmpty);
      expect(viewModel.errors['phone'], isEmpty);
    });
  });
}