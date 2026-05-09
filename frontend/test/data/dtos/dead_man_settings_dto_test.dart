import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/dead_man_settings_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/dead_man/dead_man_settings.dart';

void main() {
  Map<String, dynamic> readFixture(String name) {
    final path = Directory.current.path.endsWith('test')
        ? '../testing/fixtures/dead_man/$name'
        : 'testing/fixtures/dead_man/$name';
    final file = File(path);
    return jsonDecode(file.readAsStringSync());
  }

  group('DeadManSettingsDTO Tests', () {
    group('fromJson', () {

      test('dovrebbe fornire i valori di fallback se il JSON è vuoto o mancano i campi', () {
        // Arrange
        final json = readFixture('settings_incomplete.json');

        // Act
        final result = DeadManSettingsDTO.fromJson(json);

        // Assert
        expect(result.isActive, isFalse); // Default del booleano mancante/invalido
        expect(result.firstInactivityTimer, 60);
        expect(result.secondInactivityTimer, 15);
        expect(result.messageSubject, 'Emergenza: Mancato Check-in');
        expect(result.messageBody, 'Non ho confermato il mio stato di sicurezza.');
      });

      test('dovrebbe parsare isActive come true se fornito come int 1', () {
        // Arrange
        final json = {'is_active': 1};

        // Act
        final result = DeadManSettingsDTO.fromJson(json);

        // Assert
        expect(result.isActive, isTrue);
      });

      test('dovrebbe parsare isActive come true se fornito come int 0', () {
        // Arrange
        final json = {'is_active': 0};

        // Act
        final result = DeadManSettingsDTO.fromJson(json);

        // Assert
        expect(result.isActive, isFalse);
      });

      test('dovrebbe parsare isActive usando la chiave in camelCase (isActive) se fornita come stringa "true"', () {
        // Arrange
        final json = {'isActive': 'true'};

        // Act
        final result = DeadManSettingsDTO.fromJson(json);

        // Assert
        expect(result.isActive, isTrue);
      });

      test('dovrebbe parsare isActive come false per stringhe non valide', () {
        // Arrange
        final json = {'is_active': 'invalid_string'};

        // Act
        final result = DeadManSettingsDTO.fromJson(json);

        // Assert
        expect(result.isActive, isFalse);
      });
    });

    group('toJson', () {
      test('dovrebbe serializzare un oggetto DeadManSettings in una mappa JSON valida', () {
        // Arrange
        final settings = DeadManSettings(
          isActive: true,
          firstInactivityTimer: 90,
          secondInactivityTimer: 10,
          messageSubject: 'Test Oggetto',
          messageBody: 'Test Corpo',
        );

        // Act
        final result = DeadManSettingsDTO.toJson(settings);

        // Assert
        expect(result['is_active'], isTrue);
        expect(result['first_inactivity_timer'], 90);
        expect(result['second_inactivity_timer'], 10);
        expect(result['message_subject'], 'Test Oggetto');
        expect(result['message_body'], 'Test Corpo');
      });
    });
  });
}