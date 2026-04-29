import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import '../../utils/app_config.dart';

/// Gestisce la comunicazione di rete con AWS Cognito per il flusso di autenticazione.
///
/// Questa classe implementa il protocollo OAuth 2.0 per ottenere i token di sessione.
class AuthService {
  /// Dominio di autenticazione configurato in [AppConfig].
  final String _cognitoDomain = AppConfig.cognitoDomain;

  /// Identificativo del client recuperato tramite [AppConfig].
  final String _clientId = AppConfig.clientId;

  /// Segreto del client recuperato tramite [AppConfig].
  final String _clientSecret = AppConfig.clientSecret;

  /// URI dove l'utente viene reindirizzato dopo il login.
  final String _redirectUri = AppConfig.redirectUri;

  /// Elenco degli scopi (scopes) richiesti per ottenere i dati dell'utente.
  final List<String> _scopes = const ['profile', 'email', 'openid'];

  final http.Client _httpClient;
  AuthService({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();
  /// Avvia il flusso di login OAuth 2.0 tramite browser sicuro.
  ///
  /// Esegue la chiamata all'endpoint di autorizzazione di Google tramite Cognito.
  /// Se l'utente conferma l'accesso, scambia il codice ottenuto con i token reali.
  ///
  /// Restituisce un [Future] che contiene una [Map] con i token grezzi (id_token, access_token, ecc.).
  /// Solleva un [Exception] in caso di errore nel recupero del codice o dei token.
  Future<Map<String, dynamic>> login() async {
    final authUrl = Uri.https(_cognitoDomain, '/oauth2/authorize', {
      'response_type': 'code',
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': _scopes.join(' '),
      'identity_provider': 'Google',
      'lang': 'it',
      'prompt': 'select_account',
    });

    // Avvio dell'interfaccia web per l'autenticazione
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: AppConfig.callbackScheme,
    );

    // Estrazione del codice di autorizzazione dall'URL di ritorno
    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) {
      throw Exception('Codice di autorizzazione mancante.');
    }

    // Preparazione della richiesta per lo scambio dei token
    final basicAuth = base64Encode(utf8.encode('$_clientId:$_clientSecret'));

    final tokenResponse = await _httpClient.post(
      Uri.https(_cognitoDomain, '/oauth2/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic $basicAuth',
      },
      body: {
        'grant_type': 'authorization_code',
        'client_id': _clientId,
        'code': code,
        'redirect_uri': _redirectUri,
      },
    );

    if (tokenResponse.statusCode != 200) {
      throw Exception('Errore nel recupero dei token: ${tokenResponse.body}');
    }

    return jsonDecode(tokenResponse.body) as Map<String, dynamic>;
  }

  /// Esegue la procedura di logout richiamando l'endpoint dedicato di Cognito.
  ///
  /// Tenta di invalidare la sessione lato server aprendo brevemente l'URL di logout.
  /// Restituisce un [Future] di tipo [void].
  Future<void> logout() async {
    final url = Uri.https(_cognitoDomain, '/logout', {
      'client_id': _clientId,
      'logout_uri': _redirectUri,
    });

    try {
      await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: AppConfig.callbackScheme,
      );
    } catch (e) {
      // In caso di errore durante il redirect, logghiamo per il debug
      debugPrint('Errore durante il logout di rete: $e');
    }
  }

  /// Tenta di rinnovare i token di sessione usando un refresh token precedentemente salvato.
  ///
  /// Restituisce la mappa dei nuovi token se il refresh ha successo.
  /// Solleva un'eccezione se il refresh token è scaduto o invalido.
  Future<Map<String, dynamic>> refreshToken(String storedRefreshToken) async {
    final basicAuth = base64Encode(utf8.encode('$_clientId:$_clientSecret'));
    final tokenResponse = await _httpClient.post(
      Uri.https(_cognitoDomain, '/oauth2/token'),
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic $basicAuth',
      },
      body: {
        'grant_type': 'refresh_token',
        'client_id': _clientId,
        'refresh_token': storedRefreshToken,
      },
    );
    if (tokenResponse.statusCode != 200) {
      throw Exception('Refresh token scaduto o non valido: ${tokenResponse.body}');
    }
    final rawData = jsonDecode(tokenResponse.body) as Map<String, dynamic>;
    if (!rawData.containsKey('refresh_token')) {
      rawData['refresh_token'] = storedRefreshToken;
    }
    return rawData;
  }
}