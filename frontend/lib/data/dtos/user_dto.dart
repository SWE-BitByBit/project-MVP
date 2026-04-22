import 'dart:convert';
import '../../domain/user.dart';

/// Fornisce metodi di utilità per la conversione dei dati di autenticazione.
///
/// Traduce i dati grezzi provenienti da AWS Cognito in oggetti [User] e viceversa,
/// gestendo la decodifica dei token JWT.
class UserDTO {
  /// Converte una stringa [jsonString] contenente i token grezzi in un oggetto [User].
  ///
  /// Estrae il payload dal campo `id_token` presente in [jsonString] e lo mappa
  /// sui campi dell'oggetto di dominio.
  static User fromJson(String jsonString) {
    final Map<String, dynamic> data = jsonDecode(jsonString);

    // L'id_token è un JWT, ovvero una stringa divisa in 3 parti da un punto.
    // La parte centrale (indice 1) contiene i dati dell'utente.
    final List<String> parts = (data['id_token'] as String).split('.');
    if (parts.length != 3) {
      throw Exception('ID token non valido');
    }

    // Decodifichiamo la parte centrale (il payload)
    final String payload = base64Url.normalize(parts[1]);
    final String decoded = utf8.decode(base64Url.decode(payload));
    final Map<String, dynamic> jwtData = jsonDecode(decoded);

    // Costruiamo e restituiamo l'utente "pulito"
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
