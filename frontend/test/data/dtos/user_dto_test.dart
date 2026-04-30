import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/user_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/models/auth/user.dart';

void main() {
  Map<String, dynamic> readFixture(String name) {
    final path = Directory.current.path.endsWith('test')
        ? '../testing/fixtures/auth/$name'
        : 'testing/fixtures/auth/$name';
    final file = File(path);
    return jsonDecode(file.readAsStringSync());
  }

  group('UserDTO Tests', () {
    group('fromJson', () {
      test('dovrebbe parsare correttamente e decodificare il JWT da un payload valido (Happy Path)', () {
        // Arrange
        final json = readFixture('cognito_auth_valid.json');

        // Act
        final result = UserDTO.fromJson(json);

        // Assert
        expect(result, isA<User>());
        expect(result.sub, 'user_123');
        expect(result.email, 'mario.rossi@example.com');
        expect(result.name, 'Mario');
        expect(result.surname, 'Rossi');
        expect(result.idToken, json['id_token']);
        expect(result.accessToken, 'fake_access_token_123');
        expect(result.refreshToken, 'fake_refresh_token_456');
      });

      test('dovrebbe lanciare una Exception se il token non ha 3 parti separate da punto', () {
        // Arrange
        final json = readFixture('cognito_auth_invalid_token.json');

        // Act & Assert
        expect(
              () => UserDTO.fromJson(json),
          throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('ID token non valido'))),
        );
      });

      test('dovrebbe usare stringhe vuote come fallback se i claim mancano nel payload del JWT', () {
        // Arrange
        // Questo payload contiene e30=, che decodificato è {}
        final json = readFixture('cognito_auth_missing_claims.json');

        // Act
        final result = UserDTO.fromJson(json);

        // Assert
        expect(result.sub, '');
        expect(result.email, '');
        expect(result.name, '');
        expect(result.surname, '');
        expect(result.idToken, json['id_token']);
      });

      test('dovrebbe lanciare un errore se id_token è assente o null', () {
        // Arrange
        final json = {'access_token': 'fake_token'};

        // Act & Assert
        expect(
              () => UserDTO.fromJson(json),
          throwsA(isA<TypeError>()), // Tenta di fare .split('.') su un null/non-stringa
        );
      });
    });

    group('toJson', () {
      test('dovrebbe serializzare un oggetto User correttamente', () {
        // Arrange
        final user = User(
          sub: 'sub_789',
          email: 'luigi@test.com',
          name: 'Luigi',
          surname: 'Verdi',
          idToken: 'my_id_token',
          accessToken: 'my_access_token',
          refreshToken: 'my_refresh_token',
        );

        // Act
        final result = UserDTO.toJson(user);

        // Assert
        expect(result['sub'], 'sub_789');
        expect(result['email'], 'luigi@test.com');
        expect(result['name'], 'Luigi');
        expect(result['family_name'], 'Verdi');
        expect(result['id_token'], 'my_id_token');
        expect(result['access_token'], 'my_access_token');
        expect(result['refresh_token'], 'my_refresh_token');
      });

      test('dovrebbe gestire i campi token opzionali in fase di serializzazione', () {
        // Arrange
        final user = User(
          sub: 'sub_000',
          email: 'test@test.com',
          name: 'Test',
          surname: 'User',
          idToken: 'token',
          accessToken: 'token',
          refreshToken: null,
        );

        // Act
        final result = UserDTO.toJson(user);

        // Assert
        expect(result['refresh_token'], isNull);
      });
    });
  });
}