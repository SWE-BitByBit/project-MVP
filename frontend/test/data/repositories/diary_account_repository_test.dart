import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/diary/diary_enums.dart';
import 'package:mvp_app_protegge_e_trasforma/data/network/api_exception.dart';

import '../../../testing/mocks/diary/mock_diary_account_service.dart';

void main() {
  late MockDiaryAccountService mockService;
  late DiaryAccountRepository repository;

  setUpAll(() {
    registerFallbackValue(DiaryType.real_diary);
  });

  setUp(() {
    // Inizializza i mock per lo storage locale per evitare che
    // DiarySession.session.initSession lanci eccezioni di piattaforma
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});

    mockService = MockDiaryAccountService();
    repository = DiaryAccountRepository(mockService);
  });

  group('DiaryAccountRepository Tests', () {
    group('clarifyAccessResult', () {
      test('dovrebbe restituire real_diary in caso di successo', () async {
        // Arrange
        when(() => mockService.validateDiaryPassword(any()))
          .thenAnswer((_) async => {'diary_type': 'REAL_DIARY'});

        // Act
        final result = await repository.clarifyAccessResult('Password123!');

        // Assert
        expect(result, DiaryAccessResult.real_diary);
        verify(() => mockService.validateDiaryPassword('Password123!')).called(1);
      });

      test('dovrebbe restituire fake_diary in caso di successo con password esca', () async {
        // Arrange
        when(() => mockService.validateDiaryPassword(any()))
          .thenAnswer((_) async => {'diary_type': 'FAKE_DIARY'});

        // Act
        final result = await repository.clarifyAccessResult('FakePassword123!');

        // Assert
        expect(result, DiaryAccessResult.fake_diary);
      });

      test('dovrebbe restituire error se token o diary_type mancano nella risposta', () async {
        // Arrange
        when(() => mockService.validateDiaryPassword('Pwd!'))
            .thenAnswer((_) async => {'token': null});

        // Act
        final result = await repository.clarifyAccessResult('Pwd!');

        // Assert
        expect(result, DiaryAccessResult.error);
      });

      test('dovrebbe restituire too_many_attempts per un ApiException con statusCode 429', () async {
        // Arrange
        when(() => mockService.validateDiaryPassword('Pwd!'))
            .thenThrow(ApiException(statusCode: 429, message: 'Too many requests'));

        // Act
        final result = await repository.clarifyAccessResult('Pwd!');

        // Assert
        expect(result, DiaryAccessResult.too_many_attempts);
      });

      test('dovrebbe restituire error per un ApiException generica', () async {
        // Arrange
        when(() => mockService.validateDiaryPassword('Pwd!'))
            .thenThrow(ApiException(statusCode: 500, message: 'Server error'));

        // Act
        final result = await repository.clarifyAccessResult('Pwd!');

        // Assert
        expect(result, DiaryAccessResult.error);
      });

      test('dovrebbe restituire error per eccezioni non previste', () async {
        // Arrange
        when(() => mockService.validateDiaryPassword('Pwd!'))
            .thenThrow(Exception('Generic error'));

        // Act
        final result = await repository.clarifyAccessResult('Pwd!');

        // Assert
        expect(result, DiaryAccessResult.error);
      });
    });

    group('setPassword', () {
      test('dovrebbe restituire un errore se la password è vuota', () async {
        // Act
        final result = await repository.setPassword(newPassword: '', diaryType: DiaryType.real_diary);

        // Assert
        expect(result, 'La password non può essere vuota');
        verifyNever(() => mockService.setPassword(any(), any(), any()));
      });

      test('dovrebbe restituire un errore se la password non rispetta i criteri di sicurezza', () async {
        // Act & Assert
        expect(await repository.setPassword(newPassword: 'Short1!', diaryType: DiaryType.real_diary), 'Inserire una password valida');
        expect(await repository.setPassword(newPassword: 'lowercase123!', diaryType: DiaryType.real_diary), 'Inserire una password valida');
        expect(await repository.setPassword(newPassword: 'NoNumbersHere!', diaryType: DiaryType.real_diary), 'Inserire una password valida');
        expect(await repository.setPassword(newPassword: 'NoSpecials1234', diaryType: DiaryType.real_diary), 'Inserire una password valida');
        expect(await repository.setPassword(newPassword: 'Space 123456!', diaryType: DiaryType.real_diary), 'Inserire una password valida');
      });

      test('dovrebbe chiamare il service e restituire stringa vuota in caso di successo', () async {
        // Arrange
        when(() => mockService.setPassword(any(), any(), any()))
            .thenAnswer((_) async => {'success': true});

        // Act
        final result = await repository.setPassword(
          oldPassword: 'OldPassword123!',
          newPassword: 'ValidPassword123!',
          diaryType: DiaryType.real_diary,
        );

        // Assert
        expect(result, '');
        verify(() => mockService.setPassword('OldPassword123!', 'ValidPassword123!', DiaryType.real_diary)).called(1);
      });

      test('dovrebbe gestire l\'errore IDENTICAL_TO_REAL', () async {
        // Arrange
        when(() => mockService.setPassword(any(), any(), any()))
            .thenAnswer((_) async => {'error': 'IDENTICAL_TO_REAL'});

        // Act
        final result = await repository.setPassword(newPassword: 'ValidPassword123!', diaryType: DiaryType.fake_diary);

        // Assert
        expect(result, 'La password del diario fittizio non può essere identica alla password del diario reale');
      });

      test('dovrebbe gestire l\'errore SAME_AS_CURRENT', () async {
        // Arrange
        when(() => mockService.setPassword(any(), any(), any()))
            .thenAnswer((_) async => {'error': 'SAME_AS_CURRENT'});

        // Act
        final result = await repository.setPassword(newPassword: 'ValidPassword123!', diaryType: DiaryType.real_diary);

        // Assert
        expect(result, 'La nuova password deve essere diversa da quella attualmente in uso');
      });

      test('dovrebbe gestire eccezioni di rete in setPassword', () async {
        // Arrange
        when(() => mockService.setPassword(any(), any(), any()))
            .thenThrow(Exception('Server unreachable'));

        // Act
        final result = await repository.setPassword(newPassword: 'ValidPassword123!', diaryType: DiaryType.real_diary);

        // Assert
        expect(result, 'Errore imprevisto durante la registrazione della password.');
      });
    });

    group('checkHasRealPassword', () {
      test('dovrebbe restituire true se il service restituisce true', () async {
        // Arrange
        when(() => mockService.checkHasRealPassword()).thenAnswer((_) async => true);

        // Act
        final result = await repository.checkHasRealPassword();

        // Assert
        expect(result, isTrue);
        verify(() => mockService.checkHasRealPassword()).called(1);
      });

      test('dovrebbe restituire false se il service restituisce false', () async {
        // Arrange
        when(() => mockService.checkHasRealPassword()).thenAnswer((_) async => false);

        // Act
        final result = await repository.checkHasRealPassword();

        // Assert
        expect(result, isFalse);
      });

      test('dovrebbe restituire false (fallback sicuro) se il service lancia un\'eccezione', () async {
        // Arrange
        when(() => mockService.checkHasRealPassword()).thenThrow(Exception('Network error'));

        // Act
        final result = await repository.checkHasRealPassword();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}