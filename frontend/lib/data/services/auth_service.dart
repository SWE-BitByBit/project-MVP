import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Gestisce la comunicazione di rete con AWS Cognito per l'autenticazione.
///
/// Si occupa esclusivamente di recuperare i dati grezzi tramite i parametri di
/// configurazione come [_cognitoDomain] e [_clientId].
class AuthService {
  /// Dominio di AWS Cognito recuperato dal file .env.
  final String _cognitoDomain = dotenv.env['COGNITO_DOMAIN'] ?? '';

  /// ID Client fornito da AWS Cognito.
  final String _clientId = dotenv.env['COGNITO_CLIENT_ID'] ?? '';

  /// Segreto Client per lo scambio dei token.
  final String _clientSecret = dotenv.env['COGNITO_CLIENT_SECRET'] ?? '';

  /// URI di reindirizzamento dopo il login.
  final String _redirectUri =
      'com.bitbybit.appcheproteggeetrasforma://callback';

  /// Scopi (scopes) richiesti per l'autenticazione OAuth2.
  final List<String> _scopes = const ['profile', 'email', 'openid'];

  /// Avvia il flusso di login OAuth 2.0 con AWS Cognito e Google.
  ///
  /// Apre una pagina web sicura utilizzando [_redirectUri], attende che l'utente effettui l'accesso
  /// e scambia il codice di autorizzazione ottenuto con i token di accesso.
  /// Restituisce una [Map] contenente i token grezzi in caso di successo.
  Future<Map<String, dynamic>> login() async {
    // 1. Costruiamo l'URL per l'accesso con Google
    final authUrl = Uri.https(_cognitoDomain, '/oauth2/authorize', {
      'response_type': 'code',
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      'scope': _scopes.join(' '),
      'identity_provider': 'Google',
      'lang': 'it',
      'prompt': 'select_account',
    });

    // 2. Apriamo il browser interno e aspettiamo la risposta dell'utente
    final result = await FlutterWebAuth2.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: "com.bitbybit.appcheproteggeetrasforma",
    );

    // 3. Estraiamo il [code] temporaneo fornito da Google/Cognito
    final code = Uri.parse(result).queryParameters['code'];
    if (code == null) {
      throw Exception('Codice di autorizzazione mancante.');
    }

    // 4. Prepariamo lo scambio Codice -> Token (codificando le credenziali in Base64)
    final basicAuth = base64Encode(utf8.encode('$_clientId:$_clientSecret'));

    final tokenResponse = await http.post(
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

    // 5. Controlliamo se AWS ha restituito un esito positivo
    if (tokenResponse.statusCode != 200) {
      throw Exception(
        'Errore durante il recupero dei token: ${tokenResponse.body}',
      );
    }

    // 6. Restituiamo il dizionario dei dati grezzi ricevuti nella [tokenResponse]
    return jsonDecode(tokenResponse.body);
  }

  /// Avvia il flusso di logout sul server AWS Cognito usando [_clientId].
  ///
  /// Apre brevemente una connessione web per invalidare la sessione lato server
  /// reindirizzando l'utente su [_redirectUri].
  Future<void> logout() async {
    final url = Uri.https(_cognitoDomain, '/logout', {
      'client_id': _clientId,
      'logout_uri': _redirectUri,
    });

    try {
      await FlutterWebAuth2.authenticate(
        url: url.toString(),
        callbackUrlScheme: "com.bitbybit.appcheproteggeetrasforma",
      );
    } catch (e) {
      // Ignoriamo gli errori di chiusura finestra che possono capitare durante il logout
      print('Errore durante il logout di rete: $e');
    }
  }
}
