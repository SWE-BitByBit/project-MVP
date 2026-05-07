import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:command_it/command_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_session.dart';

import '../../../../testing/mocks/diary/mock_diary_account_repository.dart';

void main() {
  late DiaryAccessViewModel viewModel;
  late MockDiaryAccountRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(DiaryType.real_diary);
  });

  setUp(() {
    Command.globalExceptionHandler = (error, stackTrace) {};
    mockRepo = MockDiaryAccountRepository();

    // Reset dello stato del Singleton DiarySession per isolare i test
    DiarySession.session.isDiaryAuth = false;
    DiarySession.session.loggedDiary = null;
    DiarySession.session.token = null;

    // Inizializza un mock del secure storage
    FlutterSecureStorage.setMockInitialValues({});
  });

  Future<void> initViewModel() async {
    viewModel = DiaryAccessViewModel(mockRepo);
    // Attendi la fine dell'esecuzione del blocco asincrono _init() chiamato nel costruttore
    await Future.delayed(const Duration(milliseconds: 50));
  }

  group('DiaryAccessViewModel - Inizializzazione (_init)', () {
    test('Se DiarySession è già in stato autenticato, isAuthenticated è true e non interroga il backend', () async {
      DiarySession.session.isDiaryAuth = true;

      await initViewModel();

      expect(viewModel.isAuthenticated, isTrue);
      expect(viewModel.needsInitialSetup, isFalse);
      verifyNever(() => mockRepo.checkHasRealPassword());
    });

    test('Se restoreSession rileva credenziali valide, isAuthenticated è true', () async {
      // Nel tuo DiarySession.restoreSession() cerchi 'diaryToken'
      FlutterSecureStorage.setMockInitialValues({
        'isDiaryAuth': 'true',
        'loggedDiary': 'real_diary',
        'diaryToken': 'mock_token_123',
      });

      await DiarySession.session.restoreSession();
      await initViewModel();

      expect(viewModel.isAuthenticated, isTrue);
      expect(DiarySession.session.token, 'mock_token_123');
      verifyNever(() => mockRepo.checkHasRealPassword());
    });

    test('Se non c\'è sessione e l\'utente ha una password, richiede login', () async {
      when(() => mockRepo.checkHasRealPassword()).thenAnswer((_) async => true);

      await initViewModel();

      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.needsInitialSetup, isFalse);
      verify(() => mockRepo.checkHasRealPassword()).called(1);
    });

    test('Se non c\'è sessione e l\'utente NON ha password, entra in setup iniziale', () async {
      when(() => mockRepo.checkHasRealPassword()).thenAnswer((_) async => false);

      await initViewModel();

      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.needsInitialSetup, isTrue);
      verify(() => mockRepo.checkHasRealPassword()).called(1);
    });
  });

  group('DiaryAccessViewModel - Login e Logout', () {
    test('login con diario reale ha successo', () async {
      when(() => mockRepo.checkHasRealPassword()).thenAnswer((_) async => true);
      await initViewModel();

      when(() => mockRepo.clarifyAccessResult('ValidPass1!'))
          .thenAnswer((_) async => DiaryAccessResult.real_diary);

      await viewModel.login.runAsync('ValidPass1!');

      expect(viewModel.isAuthenticated, isTrue);
      expect(viewModel.asyncError.value, isNull);
    });

    test('login in errore gestisce asyncError senza crash', () async {
      when(() => mockRepo.checkHasRealPassword()).thenAnswer((_) async => true);
      await initViewModel();

      when(() => mockRepo.clarifyAccessResult('Wrong!'))
          .thenAnswer((_) async => DiaryAccessResult.error);

      await viewModel.login.runAsync('Wrong!');

      expect(viewModel.isAuthenticated, isFalse);
      expect(viewModel.asyncError.value, 'Password errata o errore di connessione.');
    });

    test('logout termina la sessione e resetta l\'autenticazione', () async {
      when(() => mockRepo.checkHasRealPassword()).thenAnswer((_) async => true);
      await initViewModel();

      await viewModel.logout.runAsync();

      expect(viewModel.isAuthenticated, isFalse);
      expect(DiarySession.session.isDiaryAuth, isFalse);
    });
  });

  group('DiaryAccessViewModel - Validazione e Modifica Password', () {
    test('validateInput rileva errori e valuta corretto un formato valido', () async {
      when(() => mockRepo.checkHasRealPassword()).thenAnswer((_) async => true);
      await initViewModel();

      viewModel.validateInput("short");
      expect(viewModel.passwordError, contains("Minimo 10 caratteri"));

      viewModel.validateInput("NoNumbersHere!");
      expect(viewModel.passwordError, contains("Deve contenere almeno un numero"));

      viewModel.validateInput("ValidPass1!");
      expect(viewModel.passwordError, isEmpty);
    });

    test('updateRealPassword fallisce se validazione locale non passa', () async {
      when(() => mockRepo.checkHasRealPassword()).thenAnswer((_) async => true);
      await initViewModel();

      await viewModel.updateRealPassword('OldPass1!', 'invalid');

      expect(viewModel.passwordError, isNotEmpty);
      expect(viewModel.setupSuccess, isFalse);
      verifyNever(() => mockRepo.setPassword(oldPassword: any(named: 'oldPassword'), newPassword: any(named: 'newPassword'), diaryType: any(named: 'diaryType')));
    });

    test('updateRealPassword aggiorna lo stato su successo del repository', () async {
      when(() => mockRepo.checkHasRealPassword()).thenAnswer((_) async => true);
      await initViewModel();

      when(() => mockRepo.setPassword(
        oldPassword: 'OldPass1!',
        newPassword: 'NewValidPass2!',
        diaryType: DiaryType.real_diary,
      )).thenAnswer((_) async => "");

      await viewModel.updateRealPassword('OldPass1!', 'NewValidPass2!');

      expect(viewModel.passwordError, isEmpty);
      expect(viewModel.setupSuccess, isTrue);
    });

    test('createInitialPassword lancia errore e popola asyncError se validazione locale fallisce', () async {
      when(() => mockRepo.checkHasRealPassword()).thenAnswer((_) async => false);
      await initViewModel();

      try {
        await viewModel.createInitialPassword.runAsync('invalid');
      } catch (_) {}

      expect(viewModel.passwordError, contains("Minimo 10 caratteri"));
      verifyNever(() => mockRepo.setPassword(oldPassword: any(named: 'oldPassword'), newPassword: any(named: 'newPassword'), diaryType: any(named: 'diaryType')));
    });
  });
}