import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/sos/view_model/sos_view_model.dart';

import '../../../../testing/mocks/trusted_contacts/mock_trusted_contact_repository.dart';
import '../../../../testing/mocks/auth/mock_auth_repository.dart';

class MockUser extends Mock implements User {}
void main() {
  late SosViewModel viewModel;
  late MockTrustedContactRepository mockContactsRepository;
  late MockAuthRepository mockAuthRepository;
  late MockUser mockUser;

  setUpAll(() {
    // Gestore globale per catturare le eccezioni asincrone di command_it durante i test di fallimento
    Command.globalExceptionHandler = (error, stackTrace) {};
  });

  setUp(() {
    mockContactsRepository = MockTrustedContactRepository();
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();

    viewModel = SosViewModel(
      contactsRepository: mockContactsRepository,
      authRepository: mockAuthRepository,
    );
  });

  group('SosViewModel - sendAlert', () {
    test('should call repository when user is authenticated', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser()).thenReturn(mockUser);
      when(() => mockContactsRepository.sendSosAlert()).thenAnswer((_) async {});

      // Act
      await viewModel.sendAlert.runAsync();

      // Assert
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verify(() => mockContactsRepository.sendSosAlert()).called(1);
    });

    test('should throw exception and not call repository when user is NOT authenticated', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser()).thenReturn(null);

      // Act
      try {
        await viewModel.sendAlert.runAsync();
        fail('L\'eccezione doveva essere lanciata');
      } catch (e) {
        // Assert
        expect(e, isException);
        expect(e.toString(), contains('Utente non autenticato'));
      }

      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verifyNever(() => mockContactsRepository.sendSosAlert());
      expect(viewModel.sendAlert.errors.value, isNotNull);
    });

    test('should capture error when repository throws an exception', () async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser()).thenReturn(mockUser);
      when(() => mockContactsRepository.sendSosAlert()).thenThrow(Exception('Network Error'));

      // Act
      try {
        await viewModel.sendAlert.runAsync();
        fail('L\'eccezione doveva essere lanciata');
      } catch (e) {
        // Assert
        expect(e, isException);
        expect(e.toString(), contains('Network Error'));
      }

      verify(() => mockContactsRepository.sendSosAlert()).called(1);
      expect(viewModel.sendAlert.errors.value, isNotNull);
    });
  });
}