/// Definisce il contratto per le comunicazioni HTTP dell'applicazione.
///
/// I Service dell'app devono dipendere da questa interfaccia e non da
/// implementazioni specifiche (come il pacchetto http o dio).
abstract class ApiClient {
  /// Esegue una richiesta GET al percorso [path].
  Future<dynamic> get(String path, {Map<String, String>? headers, bool requiresAuth = true});

  /// Esegue una richiesta POST al percorso [path] inviando il [body].
  Future<dynamic> post(String path, {Map<String, String>? headers, dynamic body, bool requiresAuth = true});

  /// Esegue una richiesta PUT al percorso [path] inviando il [body].
  Future<dynamic> put(String path, {Map<String, String>? headers, dynamic body, bool requiresAuth = true});

  /// Esegue una richiesta DELETE al percorso [path].
  Future<dynamic> delete(String path, {Map<String, String>? headers, bool requiresAuth = true});
}