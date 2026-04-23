import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import '../../../testing/mocks/auth/mock_auth_service.dart';

void main() {
  group('AuthRepository Test', () {
    late MockAuthService mockService;
    late AuthRepository repository;

    setUp(() {
      // Inizializza i finti servizi prima di ogni test
      mockService = MockAuthService();
      repository = AuthRepository(mockService);
    });

    test('Il login mappa correttamente i token nel modello User', () async {
      // Act: Eseguiamo il login
      final user = await repository.login();

      // Assert: Controlliamo i risultati
      expect(user, isNotNull);
      expect(user!.email, 'test@example.com');
      expect(user.accessToken, 'mock_access_token');
      expect(repository.isLoggedIn(), isTrue);
    });

    test('Se il service lancia errore, il repository lo cattura e restituisce null', () async {
      // Arrange: Prepariamo il mock per fallire
      mockService.shouldThrowError = true;

      // Act: Eseguiamo il login. Il try-catch nel tuo repository intercetterà l'errore.
      final user = await repository.login();

      // Assert: Ora ci aspettiamo che l'utente sia null, NON che venga lanciata l'eccezione!
      expect(user, isNull);
      expect(repository.isLoggedIn(), isFalse);
    });
  });
}