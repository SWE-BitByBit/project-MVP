import '../data/repositories/cacheable_repository.dart';

class CacheManager {
  final List<CacheableRepository> _repositories;

  CacheManager(this._repositories);

  /// Pulisce istantaneamente tutti i repository registrati.
  void clearAllCaches() {
    for (var repo in _repositories) {
      repo.clearCache();
    }
  }
}