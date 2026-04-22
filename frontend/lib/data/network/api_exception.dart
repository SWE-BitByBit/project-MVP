/// Rappresenta un errore generato durante una chiamata di rete.
class ApiException implements Exception {
  /// Codice di stato HTTP (es. 404, 401, 500).
  final int statusCode;

  /// Messaggio descrittivo dell'errore.
  final String message;

  /// Inizializza un'eccezione di rete con [statusCode] e [message].
  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: [$statusCode] $message';
}