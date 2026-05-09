import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/auth_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';

import '../../../testing/mocks/auth/mock_auth_service.dart';

void main() {
  late MockAuthService mockAuthService;
  late AuthRepository repository;

  // Payload finto per il JWT (Base64Url codificato fittizio ma parsabile da UserDTO)
  // Payload decodificato: {"sub":"user_123","email":"test@test.com","name":"Test","family_name":"User"}
  final validJwtPayload = 'eyJzdWIiOiJ1c2VyXzEyMyIsImVtYWlsIjoidGVzdEB0ZXN0LmNvbSIsIm5hbWUiOiJUZXN0IiwiZmFtaWx5X25hbWUiOiJVc2VyIn0=';

  final validAuthResponse = {
    'id_token': 'header.$validJwtPayload.signature',
    'access_token': 'fake_access_token',
    'refresh_token': 'fake_refresh_token',
  };

  setUp(() {
    // Resetta lo storage fittizio prima di ogni test
    FlutterSecureStorage.setMockInitialValues({});

    mockAuthService = MockAuthService();
    repository = AuthRepository(mockAuthService);
  });

  group('AuthRepository Tests', () {
    group('Stato Iniziale', () {
      test('isLoggedIn dovrebbe essere false e getCurrentUser null all\'avvio', () {
        expect(repository.isLoggedIn(), isFalse);
        expect(repository.getCurrentUser(), isNull);
      });
    });

    group('login', () {
      test('dovrebbe aggiornare lo stato, salvare il refresh token e restituire l\'utente in caso di successo (Happy Path)', () async {
        // Arrange
        when(() => mockAuthService.login())
            .thenAnswer((_) async => validAuthResponse);

        // Act
        final user = await repository.login();

        // Assert
        expect(user, isA<User>());
        expect(user?.email, 'test@test.com');
        expect(repository.isLoggedIn(), isTrue);
        expect(repository.getCurrentUser(), equals(user));

        final storage = const FlutterSecureStorage();
        final savedToken = await storage.read(key: 'cognito_refresh_token');
        expect(savedToken, 'fake_refresh_token');

        verify(() => mockAuthService.login()).called(1);
      });

      test('dovrebbe gestire l\'eccezione, restituire null e non loggare l\'utente in caso di errore', () async {
        // Arrange
        when(() => mockAuthService.login())
            .thenThrow(Exception('Errore di rete'));

        // Act
        final user = await repository.login();

        // Assert
        expect(user, isNull);
        expect(repository.isLoggedIn(), isFalse);

        final storage = const FlutterSecureStorage();
        final savedToken = await storage.read(key: 'cognito_refresh_token');
        expect(savedToken, isNull);
      });
    });

    group('logout', () {
      test('dovrebbe chiamare il service, resettare l\'utente e cancellare il token', () async {
        // Arrange
        // Prepariamo uno stato "loggato"
        when(() => mockAuthService.login()).thenAnswer((_) async => validAuthResponse);
        await repository.login();

        when(() => mockAuthService.logout()).thenAnswer((_) async => {});

        // Act
        await repository.logout();

        // Assert
        expect(repository.isLoggedIn(), isFalse);
        expect(repository.getCurrentUser(), isNull);

        final storage = const FlutterSecureStorage();
        final savedToken = await storage.read(key: 'cognito_refresh_token');
        expect(savedToken, isNull);

        verify(() => mockAuthService.logout()).called(1);
      });

      test('dovrebbe pulire i dati locali anche se il service lancia un\'eccezione', () async {
        // Arrange
        when(() => mockAuthService.login()).thenAnswer((_) async => validAuthResponse);
        await repository.login();

        when(() => mockAuthService.logout()).thenThrow(Exception('Errore server'));

        // Act & Assert
        await expectLater(() => repository.logout(), throwsException);

        expect(repository.isLoggedIn(), isFalse);

        final storage = const FlutterSecureStorage();
        final savedToken = await storage.read(key: 'cognito_refresh_token');
        expect(savedToken, isNull);
      });
    });

    group('restoreSession', () {
      test('dovrebbe ripristinare l\'utente se esiste un refresh token valido', () async {
        // Arrange
        FlutterSecureStorage.setMockInitialValues({
          'cognito_refresh_token': 'valid_refresh_token'
        });

        when(() => mockAuthService.refreshToken('valid_refresh_token'))
            .thenAnswer((_) async => validAuthResponse);

        // Act
        final result = await repository.restoreSession();

        // Assert
        expect(result, isTrue);
        expect(repository.isLoggedIn(), isTrue);
        expect(repository.getCurrentUser()?.email, 'test@test.com');
      });

      test('dovrebbe restituire false se non esiste un refresh token salvato', () async {
        // Act
        final result = await repository.restoreSession();

        // Assert
        expect(result, isFalse);
        expect(repository.isLoggedIn(), isFalse);
        verifyNever(() => mockAuthService.refreshToken(any()));
      });

      test('dovrebbe restituire false e cancellare il token se la chiamata di refresh fallisce', () async {
        // Arrange
        FlutterSecureStorage.setMockInitialValues({
          'cognito_refresh_token': 'expired_refresh_token'
        });

        when(() => mockAuthService.refreshToken('expired_refresh_token'))
            .thenThrow(Exception('Token scaduto'));

        // Act
        final result = await repository.restoreSession();

        // Assert
        expect(result, isFalse);
        expect(repository.isLoggedIn(), isFalse);

        final storage = const FlutterSecureStorage();
        final savedToken = await storage.read(key: 'cognito_refresh_token');
        expect(savedToken, isNull); // Il token deve essere stato eliminato
      });
    });
  });
}