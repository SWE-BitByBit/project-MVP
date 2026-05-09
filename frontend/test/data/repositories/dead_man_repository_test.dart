import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/dead_man_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/dead_man/dead_man_settings.dart';

import '../../../testing/mocks/dead_man/mock_dead_man_service.dart';

void main() {
  late MockDeadManService mockService;
  late DeadManRepository repository;

  setUp(() {
    mockService = MockDeadManService();
    repository = DeadManRepository(mockService);
  });

  group('DeadManRepository Tests', () {
    group('Stato Iniziale e Cache', () {
      test('currentSettings dovrebbe essere null all\'avvio', () {
        expect(repository.currentSettings, isNull);
      });

      test('clearCache dovrebbe resettare currentSettings a null', () async {
        // Arrange
        final rawResponse = {
          'is_active': true,
          'first_inactivity_timer': 120,
          'second_inactivity_timer': 30,
        };
        when(() => mockService.fetchSettings()).thenAnswer((_) async => rawResponse);
        await repository.getSettings();
        expect(repository.currentSettings, isNotNull);

        // Act
        repository.clearCache();

        // Assert
        expect(repository.currentSettings, isNull);
      });
    });

    group('getSettings', () {
      final rawResponse = {
        'is_active': true,
        'first_inactivity_timer': 120,
        'second_inactivity_timer': 30,
        'message_subject': 'Emergenza',
        'message_body': 'Aiuto',
      };

      test('dovrebbe scaricare i dati dal service, salvarli in cache e restituirli se la cache è vuota', () async {
        // Arrange
        when(() => mockService.fetchSettings()).thenAnswer((_) async => rawResponse);

        // Act
        final result = await repository.getSettings();

        // Assert
        expect(result.isActive, isTrue);
        expect(result.firstInactivityTimer, 120);
        expect(repository.currentSettings, equals(result));
        verify(() => mockService.fetchSettings()).called(1);
      });

      test('dovrebbe restituire la cache senza chiamare il service se i dati sono già presenti', () async {
        // Arrange
        when(() => mockService.fetchSettings()).thenAnswer((_) async => rawResponse);
        await repository.getSettings(); // Prima chiamata
        clearInteractions(mockService);

        // Act
        final result = await repository.getSettings(); // Seconda chiamata

        // Assert
        expect(result.isActive, isTrue);
        verifyNever(() => mockService.fetchSettings());
      });

      test('dovrebbe forzare la chiamata al service se forceRefresh è true', () async {
        // Arrange
        when(() => mockService.fetchSettings()).thenAnswer((_) async => rawResponse);
        await repository.getSettings(); // Prima chiamata

        // FIX: Resettiamo le interazioni del mock per azzerare il contatore delle chiamate
        clearInteractions(mockService);

        final updatedResponse = {...rawResponse, 'first_inactivity_timer': 60};
        when(() => mockService.fetchSettings()).thenAnswer((_) async => updatedResponse);

        // Act
        final result = await repository.getSettings(forceRefresh: true);

        // Assert
        expect(result.firstInactivityTimer, 60);
        expect(repository.currentSettings?.firstInactivityTimer, 60);
        verify(() => mockService.fetchSettings()).called(1); // Ora verifichiamo solo l'Act
      });
    });

    group('saveSettings', () {
      test('dovrebbe chiamare il service e aggiornare la cache locale in caso di successo', () async {
        // Arrange
        final newSettings = DeadManSettings(
          isActive: false,
          firstInactivityTimer: 90,
          secondInactivityTimer: 15,
          messageSubject: 'Test',
          messageBody: 'Body',
        );

        when(() => mockService.saveSettings(any())).thenAnswer((_) async => {});

        // Act
        await repository.saveSettings(newSettings);

        // Assert
        expect(repository.currentSettings, equals(newSettings));
        verify(() => mockService.saveSettings(any(that: isA<Map<String, dynamic>>()))).called(1);
      });

      test('non dovrebbe aggiornare la cache se il service lancia un\'eccezione', () async {
        // Arrange
        final newSettings = DeadManSettings(
          isActive: true,
          firstInactivityTimer: 90,
        );

        when(() => mockService.saveSettings(any())).thenThrow(Exception('Errore API'));

        // Act & Assert
        await expectLater(() => repository.saveSettings(newSettings), throwsException);
        expect(repository.currentSettings, isNull); // Era null in partenza, deve rimanere null
      });
    });

    group('sendHeartbeat', () {
      test('dovrebbe delegare la chiamata al service', () async {
        // Arrange
        when(() => mockService.sendHeartbeat()).thenAnswer((_) async => {});

        // Act
        await repository.sendHeartbeat();

        // Assert
        verify(() => mockService.sendHeartbeat()).called(1);
      });
    });
  });
}