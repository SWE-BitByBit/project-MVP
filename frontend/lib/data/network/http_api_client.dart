import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'api_exception.dart';

/// Implementazione di [ApiClient] basata sul pacchetto ufficiale [http].
class HttpApiClient implements ApiClient {
  /// URL base per tutte le richieste (es. API Gateway AWS).
  final String baseUrl;

  /// Funzione opzionale per recuperare dinamicamente il token di accesso.
  final Future<String?> Function()? getToken;

  /// Inizializza il client con [baseUrl] e un gestore [getToken].
  HttpApiClient({required this.baseUrl, this.getToken});

  /// Prepara gli header di default, iniettando l'Authorization se disponibile.
  Future<Map<String, String>> _prepareHeaders(Map<String, String>? customHeaders, bool requiresAuth) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?customHeaders,
    };

    if (requiresAuth && getToken != null) {
      final token = await getToken!();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  /// Gestisce la risposta HTTP, effettuando il parsing JSON o sollevando eccezioni.
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Errore di rete: ${response.body}',
      );
    }
  }

  @override
  Future<dynamic> get(String path, {Map<String, String>? headers, bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = await _prepareHeaders(headers, requiresAuth);

    final response = await http.get(uri, headers: mergedHeaders);
    return _handleResponse(response);
  }

  @override
  Future<dynamic> post(String path, {Map<String, String>? headers, dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = await _prepareHeaders(headers, requiresAuth);

    final response = await http.post(
      uri,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> put(String path, {Map<String, String>? headers, dynamic body, bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = await _prepareHeaders(headers, requiresAuth);

    final response = await http.put(
      uri,
      headers: mergedHeaders,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response);
  }

  @override
  Future<dynamic> delete(String path, {Map<String, String>? headers, bool requiresAuth = true}) async {
    final uri = Uri.parse('$baseUrl$path');
    final mergedHeaders = await _prepareHeaders(headers, requiresAuth);

    final response = await http.delete(uri, headers: mergedHeaders);
    return _handleResponse(response);
  }
}