import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart'; // <--- Nuovo import
import '../../../domain/models/safeplace/safe_place.dart';
import '../../../data/repositories/safe_place_repository.dart';
import '../../../utils/command.dart';

class SafePlaceViewModel extends ChangeNotifier {
  final SafePlaceRepository _repository;

  List<SafePlace> _safePlaces = [];
  SafePlace? _selectedPlace;

  // Variabile per salvare la posizione dell'utente
  Position? _currentPosition;

  late final Command0<void> fetchSafePlacesCommand;

  // Nuovo comando per la geolocalizzazione
  late final Command0<void> getUserLocationCommand;

  SafePlaceViewModel(this._repository) {
    fetchSafePlacesCommand = Command0<void>(_fetchSafePlaces);
    getUserLocationCommand = Command0<void>(_getUserLocation); // <--- Inizializzazione
  }

  List<SafePlace> get safePlaces => _safePlaces;
  SafePlace? get selectedPlace => _selectedPlace;
  Position? get currentPosition => _currentPosition; // <--- Getter pubblico

  Future<void> _fetchSafePlaces() async {
    _safePlaces = await _repository.getPlaces();
    notifyListeners();
  }

  void selectPlace(SafePlace place) {
    _selectedPlace = place;
    notifyListeners();
  }

  /// Metodo privato eseguito da [getUserLocationCommand].
  /// Gestisce i permessi e recupera la posizione del GPS.
  Future<void> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Controlla se il GPS è acceso
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('I servizi di localizzazione sono disabilitati. Accendi il GPS.');
    }

    // 2. Controlla i permessi dell'app
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permessi negati. Non possiamo mostrare la tua posizione.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permessi negati permanentemente. Modificali nelle impostazioni del telefono.');
    }

    // 3. Ottieni la posizione e aggiorna lo stato
    _currentPosition = await Geolocator.getCurrentPosition();
    notifyListeners();
  }
}