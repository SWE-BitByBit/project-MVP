import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/dtos/user_dto.dart';
import 'package:mvp_app_protegge_e_trasforma/domain/user.dart';

void main() {
  group('UserDTO - fromJson', () {
    test('Deve convertire correttamente una stringa JSON valida con JWT in un oggetto User', () {
      // Arrange
      // payload = {"sub":"123","email":"test@example.com","name":"Test","family_name":"User"}
      final payload = base64Url.encode(utf8.encode(jsonEncode({
        'sub': '123',
        'email': 'test@example.com',
        'name': 'Test',
        'family_name': 'User',
      }))).replaceAll('=', ''); // Rimuove il padding per simulare un JWT standard
      
      final mockJson = jsonEncode({
        'id_token': 'header.$payload.signature',
        'access_token': 'abc',
        'refresh_token': 'def',
      });

      // Act
      final user = UserDTO.fromJson(mockJson);

      // Assert
      expect(user.sub, '123');
      expect(user.email, 'test@example.com');
      expect(user.name, 'Test');
      expect(user.surname, 'User');
      expect(user.idToken, 'header.$payload.signature');
      expect(user.accessToken, 'abc');
      expect(user.refreshToken, 'def');
    });

    test('Deve lanciare un\'eccezione se l\'id_token non ha 3 parti (JWT non valido)', () {
      // Arrange
      final mockJson = jsonEncode({
        'id_token': 'test_token_invalido',
      });

      // Act & Assert
      expect(() => UserDTO.fromJson(mockJson), throwsException);
    });
  });

  group('UserDTO - toJson', () {
    test('Deve convertire correttamente un oggetto User in una Map', () {
      // Arrange
      const user = User(
        sub: '123',
        email: 'test@example.com',
        name: 'Test',
        surname: 'User',
        idToken: 'token_id',
        accessToken: 'token_access',
        refreshToken: 'token_refresh',
      );

      // Act
      final map = UserDTO.toJson(user);

      // Assert
      expect(map['sub'], '123');
      expect(map['email'], 'test@example.com');
      expect(map['name'], 'Test');
      expect(map['family_name'], 'User');
      expect(map['id_token'], 'token_id');
      expect(map['access_token'], 'token_access');
      expect(map['refresh_token'], 'token_refresh');
    });
  });
}
