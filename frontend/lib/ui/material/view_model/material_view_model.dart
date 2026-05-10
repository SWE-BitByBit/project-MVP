import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';

import '../../../domain/models/material/resource.dart';
import '../../../domain/models/material/resource_type.dart';
import '../../../data/repositories/material_repository.dart';

/// Gestisce lo stato della UI per il Materiale Informativo.
class MaterialViewModel extends ChangeNotifier {
  final MaterialRepository _repository;

  ResourceType? _currentFilter;

  late final Command<void, void> loadMaterials;

  /// Restituisce il filtro attualmente attivo, se presente.
  ResourceType? get currentFilter => _currentFilter;

  /// Legge la lista direttamente dal Repository (SSOT) e applica il filtro.
  List<Resource> get materials {
    final allResources = _repository.cachedResources;

    if (_currentFilter == null) {
      return allResources;
    }

    return allResources.where((resource) => resource.type == _currentFilter).toList();
  }

  /// Inizializza il ViewModel e configura i comandi reattivi.
  MaterialViewModel(this._repository) {
    loadMaterials = Command.createAsyncNoParam<void>(
      _loadMaterials,
      initialValue: null,
    );

    loadMaterials.run();
  }


  /// Carica la lista dei materiali dal repository e notifica la UI.
  Future<void> _loadMaterials() async {
    await _repository.fetchMaterials(forceRefresh: false);
    notifyListeners();
  }

  /// Applica o rimuove un filtro basato su [type].
  void filterByType(ResourceType type) {
    _currentFilter = (_currentFilter == type) ? null : type;
    notifyListeners();
  }

  /// Forza il ricaricamento dei dati dal server.
  Future<void> refreshMaterials() async {
    await _repository.fetchMaterials(forceRefresh: true);
    notifyListeners();
  }

  @override
  void dispose() {
    loadMaterials.dispose();
    super.dispose();
  }
}