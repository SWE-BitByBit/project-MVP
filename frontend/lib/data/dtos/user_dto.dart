import 'dart:convert';
import '../../domain/models/user.dart';

/// Fornisce metodi di utilità per la conversione dei dati di autenticazione.
///
/// Traduce i dati grezzi provenienti da AWS Cognito in oggetti [User] e viceversa,
/// gestendo la decodifica dei token JWT.
abstract class UserDTO {

  /// Converte una [Map] di dati grezzi in un oggetto [User].
  static User fromJson(Map<String, dynamic> data) {
    final List<String> parts = (data['id_token'] as String).split('.');
    if (parts.length != 3) throw Exception('ID token non valido');

    final String payload = base64Url.normalize(parts[1]);
    final String decoded = utf8.decode(base64Url.decode(payload));
    final Map<String, dynamic> jwtData = jsonDecode(decoded);

    return User(
      sub: jwtData['sub'] ?? '',
      email: jwtData['email'] ?? '',
      name: jwtData['name'] ?? '',
      surname: jwtData['family_name'] ?? '',
      idToken: data['id_token'] ?? '',
      accessToken: data['access_token'] ?? '',
      refreshToken: data['refresh_token'],
    );
  }

  /// Converte un oggetto [user] in un formato [Map] compatibile con le API esterne.
  static Map<String, dynamic> toJson(User user) {
    return {
      'sub': user.sub,
      'email': user.email,
      'name': user.name,
      'family_name': user.surname,
      'id_token': user.idToken,
      'access_token': user.accessToken,
      'refresh_token': user.refreshToken,
    };
  }


}
