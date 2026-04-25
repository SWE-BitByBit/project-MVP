import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import 'package:geolocator/geolocator.dart';

import '../../../domain/models/safeplace/safe_place.dart';
import '../../../data/repositories/safe_place_repository.dart';
import '../../../data/services/location_service.dart';

/// Gestisce lo stato della UI per i Luoghi Sicuri.
///
/// Interagisce con [SafePlaceRepository] per i dati e usa [command_it]
/// per esporre stati reattivi di caricamento ed errore alla UI (Mappa).
class SafePlaceViewModel extends ChangeNotifier {
  final SafePlaceRepository _repository;
  final LocationService _locationService;

  // --- STATO LOCALE DELLA UI ---
  SafePlace? _selectedPlace;
  Position? _userPosition;

  // Sintassi moderna di command_it
  late final Command<void, void> loadPlaces;
  late final Command<void, void> getUserLocation;

  // --- GETTER PROTETTI (Single Source of Truth) ---
  /// Leggiamo la lista direttamente dal Repository senza duplicarla.
  List<SafePlace> get safePlaces => _repository.cachedPlaces;

  /// Espone lo stato della sessione della mappa (coordinate e zoom dell'ultima visita).
  MapSessionState? get cachedMapState => _repository.cachedMapState;

  SafePlace? get selectedPlace => _selectedPlace;
  Position? get userPosition => _userPosition;

  /// Inizializza il ViewModel e configura i comandi reattivi.
  SafePlaceViewModel(
      this._repository, {
        required LocationService locationService,
      }) : _locationService = locationService {

    // Inizializzazione comandi
    loadPlaces = Command.createAsyncNoParam<void>(
      _loadPlaces,
      initialValue: null,
    );

    getUserLocation = Command.createAsyncNoParam<void>(
      _getUserLocation,
      initialValue: null,
    );

    // Caricamento iniziale al boot del ViewModel
    loadPlaces.run();
    getUserLocation.run();
  }

  // --- METODI PRIVATI DEI COMANDI ---

  /// Carica la lista dei luoghi dal repository e notifica la UI.
  Future<void> _loadPlaces() async {
    // Il repository aggiorna la sua cache interna ottimizzata
    await _repository.getPlaces();
    notifyListeners();
  }

  /// Gestisce i permessi e recupera la posizione GPS dell'utente.
  Future<void> _getUserLocation() async {
    final serviceEnabled = await _locationService.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('I servizi di localizzazione sono disabilitati. Accendi il GPS.');
    }

    var permission = await _locationService.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _locationService.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permessi negati. Non possiamo mostrare la tua posizione.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permessi negati permanentemente. Modificali nelle impostazioni.');
    }

    _userPosition = await _locationService.getCurrentPosition();
    notifyListeners();
  }

  // --- AZIONI UI (Sincrone) ---

  /// Seleziona un luogo per mostrarne i dettagli (es. in una BottomSheet).
  void selectPlace(SafePlace? place) {
    _selectedPlace = place;
    notifyListeners();
  }

  /// Salva lo stato visivo della mappa nel Repository in modo "silenzioso"
  /// (senza chiamare notifyListeners per non far sfarfallare la UI).
  void saveMapSessionState(double lat, double lng, double zoom) {
    _repository.cachedMapState = (latitude: lat, longitude: lng, zoom: zoom);
  }

  @override
  void dispose() {
    loadPlaces.dispose();
    getUserLocation.dispose();
    super.dispose();
  }
}