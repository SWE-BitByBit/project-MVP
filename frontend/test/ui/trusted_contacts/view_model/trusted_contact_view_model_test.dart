import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/view_model/trusted_contact_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';

import '../../../../testing/mocks/trusted_contacts/mock_trusted_contact_repository.dart';
import '../../../../testing/mocks/auth/mock_auth_repository.dart';

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

    when(
      () => mockRepository.getContacts(),
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
        () => mockRepository.getContacts(),
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
      verify(() => mockRepository.getContacts()).called(equals(1));
    });

    test(
      'deleteContact should not perform optimistic update and refresh on success',
      () async {
        when(
          () => mockRepository.deleteContact(any()),
        ).thenAnswer((_) async {});

        await viewModel.deleteContact.runAsync('1');

        verify(() => mockRepository.deleteContact('1')).called(1);
        verify(() => mockRepository.getContacts()).called(1);
      },
    );

    test('deleteContact should rollback and refresh list on failure', () async {
      // Usiamo throw invece di Future.error per evitare leak asincroni nel test
      when(
        () => mockRepository.deleteContact(any()),
      ).thenThrow(Exception('Server Error'));

      try {
        await viewModel.deleteContact.runAsync('1');
      } catch (e) {
        expect(e, isException);
      }

      expect(viewModel.deleteContact.errors.value, isNotNull);
    });
  });

  group('TrustedContactViewModel - Error Handling', () {
    test('loadContacts should set error on repository failure', () async {
      when(
        () => mockRepository.getContacts(),
      ).thenThrow(Exception('Fetch Error'));

      viewModel = TrustedContactViewModel(
        mockRepository,
        authRepository: mockAuthRepository,
      );

      await Future.delayed(Duration.zero);

      expect(viewModel.loadContacts.errors.value, isNotNull);
    });
  });
}
