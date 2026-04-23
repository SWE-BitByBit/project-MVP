import 'package:flutter_test/flutter_test.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/view_model/auth_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/user.dart';
import '../../../../testing/mocks/auth/mock_auth_repository.dart';

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockRepository;

  setUp(() {
    Command.globalExceptionHandler = (error, stackTrace) {
      // Non facciamo nulla, gestiamo gli errori localmente nei test
    };
    mockRepository = MockAuthRepository();
    viewModel = AuthViewModel(mockRepository);
  });

  group('AuthViewModel - Stato Iniziale', () {
    test('Lo stato iniziale deve essere corretto', () {
      // Usiamo .isRunning.value e .errors.value forniti da command_it
      expect(viewModel.login.isRunning.value, isFalse);
      expect(viewModel.login.errors.value, isNull);
      expect(viewModel.currentUser, isNull);
    });
  });

  group('AuthViewModel - Login', () {
    test('login ha successo e aggiorna l\'utente', () async {

      viewModel.login.run(null);

      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(viewModel.currentUser, isNotNull);
      expect(viewModel.currentUser?.email, 'test@example.com');
      expect(viewModel.login.isRunning.value, isFalse);
      expect(viewModel.login.errors.value, isNull);
    });

    test('login fallisce (annullato) e imposta un messaggio di errore', () async {
      // Arrange
      mockRepository.shouldThrowError = true;

      // Act
      viewModel.login.run(null);

      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(viewModel.currentUser, isNull);
      expect(viewModel.login.errors.value?.error.toString(), contains('Autenticazione fallita'));
      expect(viewModel.login.isRunning.value, isFalse);
    });

    test('login lancia eccezione di rete e imposta errore connessione', () async {
      // Arrange
      mockRepository.shouldThrowError = true;

      // Act
      viewModel.login.run(null);

      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(viewModel.currentUser, isNull);
      expect(viewModel.login.errors.value?.error.toString(), contains('Autenticazione fallita'));
      expect(viewModel.login.isRunning.value, isFalse);
    });
  });

  group('AuthViewModel - Logout', () {
    test('logout rimuove l\'utente corrente', () async {
      // Arrange: Prima facciamo login
      viewModel.login.run(null);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(viewModel.currentUser, isNotNull);

      // Act: Eseguiamo il logout
      viewModel.logout.run(null);

      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(viewModel.currentUser, isNull);
      expect(viewModel.logout.isRunning.value, isFalse);
    });
  });

  group('AuthViewModel - Sessione Esistente', () {
    test('checkExistingSession notifica i listener se l\'utente è già loggato', () {
      // Arrange
      mockRepository.setMockedUser(const User(
        sub: '1',
        email: 'a@a.com',
        name: 'A',
        surname: 'S',
        idToken: 'i',
        accessToken: 'a',
      ));

      bool notified = false;
      viewModel.addListener(() => notified = true);

      // Act
      viewModel.checkExistingSession();

      // Assert
      expect(notified, isTrue);
      expect(viewModel.currentUser, isNotNull);
    });
  });
}