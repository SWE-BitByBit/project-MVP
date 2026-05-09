import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Classe centralizzata per tutte le configurazioni d'ambiente dell'applicazione.
///
/// Fornisce l'accesso alle variabili definite nel file [.env] garantendo
/// valori di fallback sicuri.
class AppConfig {
  /// Costruttore privato per impedire l'istanziazione di [AppConfig].
  AppConfig._();

  /// Restituisce l'URL base dell'API per i servizi di backend.
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:3000';

  /// Restituisce il dominio di AWS Cognito per l'autenticazione.
  static String get cognitoDomain => dotenv.env['COGNITO_DOMAIN'] ?? '';

  /// Restituisce l'ID Client per l'integrazione con AWS Cognito.
  static String get clientId => dotenv.env['COGNITO_CLIENT_ID'] ?? '';

  /// Restituisce il segreto client necessario per lo scambio dei token.
  static String get clientSecret => dotenv.env['COGNITO_CLIENT_SECRET'] ?? '';

  /// Definisce lo schema di callback personalizzato per l'app.
  static String get callbackScheme => "com.bitbybit.appcheproteggeetrasforma";

  /// Restituisce l'URI completo di reindirizzamento post-autenticazione.
  static String get redirectUri => "$callbackScheme://callback";
}