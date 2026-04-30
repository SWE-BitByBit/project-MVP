import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/trusted_contact_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/trusted_contact/trusted_contact.dart';

void main() {
  Map<String, dynamic> readFixture(String name) {
    final path = Directory.current.path.endsWith('test')
        ? '../testing/fixtures/trusted_contacts/$name'
        : 'testing/fixtures/trusted_contacts/$name';
    final file = File(path);
    return jsonDecode(file.readAsStringSync());
  }

  group('TrustedContactDTO Tests', () {
    group('fromJson', () {
      test('dovrebbe parsare correttamente un JSON valido (Happy Path)', () {
        // Arrange
        final json = readFixture('trusted_contact_valid.json');

        // Act
        final result = TrustedContactDTO.fromJson(json);

        // Assert
        expect(result, isA<TrustedContact>());
        expect(result.id, 'tc_123');
        expect(result.name, 'Maria Rossi');
        expect(result.email, 'maria.rossi@example.com');
        expect(result.phoneNumber, '+393331234567');
      });

      test('dovrebbe gestire campi mancanti fornendo stringhe vuote come default', () {
        // Arrange
        final json = readFixture('trusted_contact_incomplete.json');

        // Act
        final result = TrustedContactDTO.fromJson(json);

        // Assert
        expect(result.id, '');
        expect(result.name, '');
        expect(result.email, '');
        expect(result.phoneNumber, '');
      });

      test('dovrebbe convertire in stringa i valori numerici passati inavvertitamente', () {
        // Arrange
        final json = {
          'contactId': 999,
          'name': 12345,
          'phoneNumber': 3331234567
        };

        // Act
        final result = TrustedContactDTO.fromJson(json);

        // Assert
        expect(result.id, '999');
        expect(result.name, '12345');
        expect(result.phoneNumber, '3331234567');
        expect(result.email, ''); // Email mancante
      });
    });

    group('toJson', () {
      test('dovrebbe serializzare correttamente un oggetto TrustedContact in JSON', () {
        // Arrange
        final contact = TrustedContact(
          id: 'tc_456',
          name: 'Luigi Bianchi',
          email: 'luigi@test.com',
          phoneNumber: '+390001112233',
        );

        // Act
        final result = TrustedContactDTO.toJson(contact);

        // Assert
        expect(result['contactId'], 'tc_456');
        expect(result['name'], 'Luigi Bianchi');
        expect(result['email'], 'luigi@test.com');
        expect(result['phoneNumber'], '+390001112233');
      });

      test('dovrebbe serializzare correttamente un TrustedContact con campi vuoti', () {
        // Arrange
        final contact = TrustedContact(
          id: '',
          name: '',
          email: '',
          phoneNumber: '',
        );

        // Act
        final result = TrustedContactDTO.toJson(contact);

        // Assert
        expect(result['contactId'], '');
        expect(result['name'], '');
        expect(result['email'], '');
        expect(result['phoneNumber'], '');
      });
    });
  });
}