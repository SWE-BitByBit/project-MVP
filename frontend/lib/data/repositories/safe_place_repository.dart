import '../../domain/models/safeplace/safe_place.dart';
import '../services/safe_place_service.dart';
import '../dtos/safe_place_dto.dart';

/// Repository per la gestione dei dati relativi ai luoghi sicuri.
///
/// Rappresenta la fonte di verità e orchestra l'accesso al [SafePlaceService][cite: 323].
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
      // 1. Recupera i dati grezzi dal Service
      final rawData = await _service.fetchSafePlaces();

      // NOTA: Poiché l'UML indica che il Service ritorna una Map<String, dynamic>,
      // assumiamo che il JSON del backend abbia un contenitore (es. una chiave 'data' o 'places')
      // che racchiude la vera e propria lista di oggetti.
      // Se il tuo backend restituisce direttamente un array JSON, dovremmo aggiornare il Service.
      final List<dynamic> rawList = rawData['data'] ?? [];

      // 2. Converte ogni elemento della lista grezza in un oggetto di Dominio tramite il DTO
      final List<SafePlace> places = rawList.map((jsonItem) {
        return SafePlaceDTO.fromJson(jsonItem as Map<String, dynamic>);
      }).toList();

      return places;
    } catch (e) {
      // Qui potresti loggare l'errore in un sistema di crashlytics
      throw Exception("Errore nel repository durante l'elaborazione dei luoghi sicuri: $e");
      }
      }
}
