import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/user.dart';
import '../../../testing/mocks/mock_auth_service.dart';

void main() {
  late AuthRepository repository;
  late MockAuthService mockService;

  setUp(() {
    mockService = MockAuthService();
    repository = AuthRepository(mockService);
  });

  group('AuthRepository - Login', () {
    test('login ha successo e restituisce l\'utente quando il service risponde correttamente', () async {
      // Arrange
      // "header.payload.signature" dove payload è {"sub":"123-uid","email":"test@example.com","name":"Test User"} base64url encoded
      const payload = 'eyJzdWIiOiIxMjMtdWlkIiwiZW1haWwiOiJ0ZXN0QGV4YW1wbGUuY29tIiwibmFtZSI6IlRlc3QgVXNlciJ9';
      const mockJwt = 'header.$payload.signature';

      mockService.mockedTokenResponse = {
        'access_token': 'abc',
        'id_token': mockJwt,
      };

      // Act
      final user = await repository.login();

      // Assert
      expect(user, isA<User>());
      expect(user?.email, 'test@example.com');
      expect(repository.getCurrentUser(), isNotNull);
      expect(repository.isLoggedIn(), isTrue);
    });

    test('login restituisce null in caso di errore nel service', () async {
      // Arrange
      mockService.shouldThrowError = true;

      // Act
      final user = await repository.login();

      // Assert
      expect(user, isNull);
      expect(repository.getCurrentUser(), isNull);
      expect(repository.isLoggedIn(), isFalse);
    });
  });

  group('AuthRepository - Logout', () {
    test('logout pulisce l\'utente corrente', () async {
      // Arrange: simuliamo un utente loggato
      const payload = 'eyJzdWIiOiIxMjMtdWlkIiwiZW1haWwiOiJ0ZXN0QGV4YW1wbGUuY29tIiwibmFtZSI6IlRlc3QgVXNlciJ9';
      const mockJwt = 'header.$payload.signature';
      mockService.mockedTokenResponse = {
        'access_token': 'abc',
        'id_token': mockJwt,
      };
      await repository.login();
      expect(repository.isLoggedIn(), isTrue);

      // Act
      await repository.logout();

      // Assert
      expect(repository.getCurrentUser(), isNull);
      expect(repository.isLoggedIn(), isFalse);
    });
  });
}
