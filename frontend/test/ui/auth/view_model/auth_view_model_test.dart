import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/auth/view_model/auth_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/dead_man_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/utils/cache_manager.dart';
import 'package:mvp_app_protegge_e_trasforma/utils/locator.dart';

import '../../../../testing/mocks/auth/mock_auth_repository.dart';
import '../../../../testing/mocks/dead_man/mock_dead_man_repository.dart';
import '../../../../testing/mocks/core/mock_cache_manager.dart';

class FakeUser extends Fake implements User {}

void main() {
  late AuthViewModel viewModel;
  late MockAuthRepository mockAuthRepository;
  late MockDeadManRepository mockDeadManRepository;
  late MockCacheManager mockCacheManager;

  setUp(() {
    Command.globalExceptionHandler = (error, stackTrace) {};

    mockAuthRepository = MockAuthRepository();
    mockDeadManRepository = MockDeadManRepository();
    mockCacheManager = MockCacheManager();

    getIt.registerSingleton<DeadManRepository>(mockDeadManRepository);
    getIt.registerSingleton<CacheManager>(mockCacheManager);

    viewModel = AuthViewModel(mockAuthRepository);
  });

  tearDown(() {
    getIt.reset();
  });

  group('AuthViewModel - Initial State', () {
    test('isInitializing dovrebbe essere true di default', () {
      expect(viewModel.isInitializing, isTrue);
    });

    test('currentUser dovrebbe restituire l\'utente dal repository', () {
      final fakeUser = FakeUser();
      when(() => mockAuthRepository.getCurrentUser()).thenReturn(fakeUser);

      final user = viewModel.currentUser;

      expect(user, fakeUser);
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
    });
  });

  group('AuthViewModel - checkExistingSession', () {
    test('dovrebbe chiamare restoreSession se l\'utente non è loggato e notificare i listener', () async {
      when(() => mockAuthRepository.isLoggedIn()).thenReturn(false);
      when(() => mockAuthRepository.restoreSession()).thenAnswer((_) async {return true;});

      bool listenerCalled = false;
      viewModel.addListener(() => listenerCalled = true);

      await viewModel.checkExistingSession();

      verify(() => mockAuthRepository.isLoggedIn()).called(1);
      verify(() => mockAuthRepository.restoreSession()).called(1);
      expect(viewModel.isInitializing, isFalse);
      expect(listenerCalled, isTrue);
    });

    test('non dovrebbe chiamare restoreSession se l\'utente è loggato', () async {
      when(() => mockAuthRepository.isLoggedIn()).thenReturn(true);

      await viewModel.checkExistingSession();

      verify(() => mockAuthRepository.isLoggedIn()).called(1);
      verifyNever(() => mockAuthRepository.restoreSession());
      expect(viewModel.isInitializing, isFalse);
    });
  });

  group('AuthViewModel - login Command', () {
    test('dovrebbe eseguire il login con successo e inviare l\'heartbeat', () async {
      final fakeUser = FakeUser();
      when(() => mockAuthRepository.login()).thenAnswer((_) async => fakeUser);
      when(() => mockDeadManRepository.sendHeartbeat()).thenAnswer((_) async {});

      bool listenerCalled = false;
      viewModel.addListener(() => listenerCalled = true);

      await viewModel.login.runAsync();

      verify(() => mockAuthRepository.login()).called(1);
      verify(() => mockDeadManRepository.sendHeartbeat()).called(1);
      expect(viewModel.login.errors.value, isNull);
      expect(listenerCalled, isTrue);
    });

    test('dovrebbe gestire il fallimento dell\'heartbeat senza fallire il login', () async {
      final fakeUser = FakeUser();
      when(() => mockAuthRepository.login()).thenAnswer((_) async => fakeUser);
      when(() => mockDeadManRepository.sendHeartbeat()).thenThrow(Exception('Errore rete'));

      await viewModel.login.runAsync();

      verify(() => mockAuthRepository.login()).called(1);
      verify(() => mockDeadManRepository.sendHeartbeat()).called(1);

      expect(viewModel.login.errors.value, isNull);
    });

    test('dovrebbe generare un errore se il login restituisce null', () async {
      when(() => mockAuthRepository.login()).thenAnswer((_) async => null);

      try {
        await viewModel.login.runAsync();
      } catch (_) {}

      verify(() => mockAuthRepository.login()).called(1);
      verifyNever(() => mockDeadManRepository.sendHeartbeat());
      expect(viewModel.login.errors.value, isNotNull);
      expect(
        viewModel.login.errors.value?.error.toString(),
        contains('Autenticazione fallita o annullata'),
      );
    });

    test('dovrebbe generare un errore se il repository lancia un\'eccezione', () async {
      when(() => mockAuthRepository.login()).thenThrow(Exception('Errore API'));

      try {
        await viewModel.login.runAsync();
      } catch (_) {}

      verify(() => mockAuthRepository.login()).called(1);
      verifyNever(() => mockDeadManRepository.sendHeartbeat());
      expect(viewModel.login.errors.value, isNotNull);
    });
  });

  group('AuthViewModel - logout Command', () {
    test('dovrebbe eseguire il logout dal repository e pulire la cache', () async {
      when(() => mockAuthRepository.logout()).thenAnswer((_) async {});
      when(() => mockCacheManager.clearAllCaches()).thenAnswer((_) async {});

      bool listenerCalled = false;
      viewModel.addListener(() => listenerCalled = true);

      await viewModel.logout.runAsync();

      verify(() => mockAuthRepository.logout()).called(1);
      verify(() => mockCacheManager.clearAllCaches()).called(1);
      expect(viewModel.logout.errors.value, isNull);
      expect(listenerCalled, isTrue);
    });

    test('dovrebbe generare un errore se il repository di logout fallisce', () async {
      when(() => mockAuthRepository.logout()).thenThrow(Exception('Logout fallito'));

      try {
        await viewModel.logout.runAsync();
      } catch (_) {}

      verify(() => mockAuthRepository.logout()).called(1);
      verifyNever(() => mockCacheManager.clearAllCaches());
      expect(viewModel.logout.errors.value, isNotNull);
    });
  });
}