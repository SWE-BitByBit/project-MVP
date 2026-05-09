/// Interfaccia che obbliga i repository a implementare la pulizia dei dati.
abstract class CacheableRepository {
  void clearCache();
}