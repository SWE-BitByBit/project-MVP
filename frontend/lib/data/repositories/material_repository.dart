import '../../domain/resource.dart';
import '../services/material_service.dart';
import '../dtos/resource_dto.dart';

/// Repository responsabile della gestione dei materiali informativi.
///
/// Agisce come singola fonte di verità per l'interfaccia utente. Preleva i dati
/// grezzi tramite [_service], li converte in oggetti di dominio utilizzando
/// [ResourceDTO] e li mantiene in una cache locale [_materials].
class MaterialRepository {
  /// Il servizio utilizzato per recuperare i dati dal backend.
  final MaterialService _service;

  /// Cache interna dei materiali già scaricati e tradotti.
  List<Resource> _materials = [];

  /// Inizializza il repository associando il [MaterialService] necessario.
  MaterialRepository(this._service);

  /// Recupera la lista dei materiali informativi.
  ///
  /// Se la lista [_materials] non è vuota, restituisce immediatamente i dati in
  /// memoria. Altrimenti, richiede i dati al servizio, li mappa e li salva.
  Future<List<Resource>> getMaterials() async {
    // 1. Controllo della cache: se abbiamo già i dati, li restituiamo subito!
    if (_materials.isNotEmpty) {
      return _materials;
    }

    // 2. Chiediamo al Service di fare il "lavoro sporco" e scaricare i JSON grezzi
    final rawData = await _service.fetchMaterials();

    // 3. Traduciamo la lista: prendiamo ogni "json", lo passiamo al DTO
    // e trasformiamo il tutto in una vera e propria List<Resource>
    _materials = rawData.map((json) => ResourceDTO.fromJson(json)).toList();

    // 4. Restituiamo i dati pronti all'uso
    return _materials;
  }
}
