import 'dart:collection';
import '../../domain/models/material/resource.dart';
import '../services/material_service.dart';
import '../dtos/resource_dto.dart';
import 'cacheable_repository.dart';

/// Repository responsabile della gestione dei materiali informativi.
///
/// Implementa [CacheableRepository] e funge da Single Source of Truth (SSOT).
class MaterialRepository implements CacheableRepository {
  final MaterialService _service;

  final List<Resource> _cachedResources = [];
  MaterialRepository({required MaterialService service}) : _service = service;
  List<Resource> get cachedResources => UnmodifiableListView(_cachedResources);

  /// Recupera i materiali.
  /// Se [forceRefresh] è true, ignora la cache e scarica i dati aggiornati.
  Future<List<Resource>> fetchMaterials({bool forceRefresh = false}) async {
    if (_cachedResources.isEmpty || forceRefresh) {
      final Map<String, dynamic> rawData = await _service.fetchMaterials();
      final List<dynamic> rawList = rawData['data'] ?? [];

      final fetchedResources = rawList
          .map((json) => ResourceDTO.fromJson(json as Map<String, dynamic>))
          .toList();

      _cachedResources.clear();
      _cachedResources.addAll(fetchedResources);
    }
    return cachedResources;
  }

  @override
  void clearCache() {
    _cachedResources.clear();
  }
}
