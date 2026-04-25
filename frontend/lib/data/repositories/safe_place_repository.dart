import '../../domain/models/safeplace/safe_place.dart';
import '../dtos/safe_place_dto.dart';
import '../services/safe_place_service.dart';
import 'cacheable_repository.dart';

/// Definiamo un Record per raggruppare lo stato visivo della mappa.
/// Questo evita di sporcare il Data Layer con classi UI di Google Maps.
typedef MapSessionState = ({double latitude, double longitude, double zoom});

/// Intermediario tra il ViewModel e il livello dati (Service) per i luoghi sicuri.
class SafePlaceRepository implements CacheableRepository {
  final SafePlaceService _safePlaceService;

  /// Cache locale dei luoghi sicuri. 
  final List<SafePlace> _cachedPlaces = [];

  List<SafePlace> get cachedPlaces => List.unmodifiable(_cachedPlaces);

  // --- STATO DI SESSIONE DELLA MAPPA RAGGRUPPATO ---
  // Invece di 3 variabili sciolte, usiamo il nostro Record opzionale.
  MapSessionState? cachedMapState;

  SafePlaceRepository(this._safePlaceService);

  Future<List<SafePlace>> getPlaces({bool forceRefresh = false}) async {
    if (_cachedPlaces.isEmpty || forceRefresh) {
      final Map<String, dynamic> rawData = await _safePlaceService.fetchSafePlaces();
      final List<dynamic> rawList = rawData['data'] ?? [];

      final newPlaces = rawList
          .map((json) => SafePlaceDTO.fromJson(json as Map<String, dynamic>))
          .toList();

      _cachedPlaces.clear();
      _cachedPlaces.addAll(newPlaces);
    }

    return cachedPlaces;
  }

  @override
  void clearCache() {
    _cachedPlaces.clear();
    cachedMapState = null;
  }
}