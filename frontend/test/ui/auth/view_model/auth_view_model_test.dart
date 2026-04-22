import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/view_model/auth_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/user.dart';
import '../../../../testing/mocks/mock_auth_repository.dart';

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = AuthViewModel(mockRepository);
  });

  group('AuthViewModel - Stato Iniziale', () {
    test('Lo stato iniziale deve essere corretto', () {
      expect(viewModel.login.running, isFalse);
      expect(viewModel.login.error, isNull);
      expect(viewModel.currentUser, isNull);
    });
  });

  group('AuthViewModel - Login', () {
    test('login ha successo e aggiorna l\'utente', () async {
      // Arrange
      // Il mock restituisce un utente di default in caso di successo
      
      // Act
      await viewModel.login.execute();

      // Assert
      expect(viewModel.currentUser, isNotNull);
      expect(viewModel.currentUser?.email, 'test@example.com');
      expect(viewModel.login.running, isFalse);
      expect(viewModel.login.error, isNull);
    });

    test('login fallisce e imposta un messaggio di errore', () async {
      // Arrange
      mockRepository.shouldThrowError = true;

      // Act
      await viewModel.login.execute();

      // Assert
      expect(viewModel.currentUser, isNull);
      expect(viewModel.login.error.toString(), contains('Autenticazione fallita'));
      expect(viewModel.login.running, isFalse);
    });

    test('login lancia eccezione e imposta errore connessione', () async {
      // Arrange
      mockRepository.shouldThrowException = true;

      // Act
      await viewModel.login.execute();

      // Assert
      expect(viewModel.currentUser, isNull);
      expect(viewModel.login.error.toString(), contains('errore di connessione'));
      expect(viewModel.login.running, isFalse);
    });
  });

  group('AuthViewModel - Logout', () {
    test('logout rimuove l\'utente corrente', () async {
      // Arrange
      await viewModel.login.execute();
      expect(viewModel.currentUser, isNotNull);

      // Act
      await viewModel.logout.execute();

      // Assert
      expect(viewModel.currentUser, isNull);
      expect(viewModel.logout.running, isFalse);
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
