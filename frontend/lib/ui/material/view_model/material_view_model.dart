import 'package:flutter/foundation.dart';
import '../../../domain/models/material/resource.dart';
import '../../../domain/models/material/resource_type.dart';
import '../../../data/repositories/material_repository.dart';
import '../../../utils/command.dart';

/// Classe del layer UI responsabile della logica di presentazione per i materiali.
///
/// Interagisce con [MaterialRepository] per recuperare i dati e gestisce
/// il filtraggio delle risorse. Espone lo stato alla UI tramite il pattern Command.
class MaterialViewModel extends ChangeNotifier {
  /// Il repository da cui prelevare le informazioni.
  final MaterialRepository _repository;

  /// Lista interna contenente tutti i materiali scaricati.
  List<Resource> _allMaterials = [];

  /// Tipologia di risorsa attualmente selezionata per il filtraggio.
  ResourceType? _currentFilter;

  /// Comando reattivo per il caricamento asincrono dei materiali.
  late final Command0<void> loadMaterials;


  /// Inizializza il view model associando il [_repository] e configurando il comando.
  MaterialViewModel(this._repository) {
    loadMaterials = Command0<void>(_loadMaterials);
    loadMaterials.addListener(notifyListeners);
  }

  /// Restituisce il filtro attualmente attivo, se presente.
  ResourceType? get currentFilter => _currentFilter;

  /// Restituisce la lista dei materiali da mostrare nella UI.
  ///
  /// Se [_currentFilter] è impostato, restituisce solo gli elementi corrispondenti.
  /// Altrimenti restituisce l'intera lista [_allMaterials].
  List<Resource> get materials {
    if (_currentFilter == null) {
      return _allMaterials;
    }
    return _allMaterials
        .where((resource) => resource.type == _currentFilter)
        .toList();
  }

  /// Metodo privato eseguito automaticamente dal comando [loadMaterials].
  ///
  /// Recupera i dati tramite [_repository] e notifica i listener della UI.
  Future<void> _loadMaterials() async {
    _allMaterials = await _repository.getMaterials();
    notifyListeners();
  }

  /// Applica o rimuove un filtro basato su [type].
  ///
  /// Funziona come un toggle: se il filtro selezionato è già quello attivo,
  /// lo rimuove (impostandolo a null).
  void filterByType(ResourceType type) {
    _currentFilter = (_currentFilter == type) ? null : type;
    notifyListeners();
  }
}
