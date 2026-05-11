import '../../domain/models/safeplace/safe_place.dart';
import '../services/safe_place_service.dart';
import '../dtos/safe_place_dto.dart';

/// Repository per la gestione dei dati relativi ai luoghi sicuri.
///
/// Rappresenta la fonte di verità e orchestra l'accesso al [SafePlaceService].
class SafePlaceRepository {
  /// Il servizio utilizzato per le chiamate di rete.
  final SafePlaceService _service;

  /// Crea un'istanza di [SafePlaceRepository] iniettando il [SafePlaceService].
  const SafePlaceRepository(this._service);

  /// Recupera la lista dei luoghi sicuri.
  ///
  /// Chiama il servizio remoto e utilizza [SafePlaceDTO] per convertire
  /// la risposta in una lista di oggetti di dominio [SafePlace].
  Future<List<SafePlace>> getPlaces() async {
    try {
      final List<Map<String, dynamic>> rawList = await _service
          .fetchSafePlaces();

      return rawList.map((jsonItem) {
        return SafePlaceDTO.fromJson(jsonItem);
      }).toList();
    } catch (e) {
      throw Exception(
        "Errore nel repository durante l'elaborazione dei luoghi sicuri: $e",
      );
    }
  }
}
