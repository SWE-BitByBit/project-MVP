import 'dart:async';
import 'package:mvp_app_protegge_e_trasforma/domain/models/safeplace/safe_place.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/safe_place_repository.dart';

/// Mock del Repository per isolare il test del ViewModel.
class MockSafePlaceRepository implements SafePlaceRepository {
  bool shouldFail = false;

  /// Questo Completer permette di controllare manualmente quando
  /// la funzione getPlaces deve rispondere durante i test.
  Completer<List<SafePlace>>? completer;

  @override
  Future<List<SafePlace>> getPlaces() async {
    // Se nel test abbiamo impostato un completer, restituiamo il suo Future.
    // L'esecuzione rimarrà bloccata qui finché non completeremo il completer nel test.
    if (completer != null) {
      return completer!.future;
    }

    if (shouldFail) {
      throw Exception('Errore simulato dal repository');
    }

    // Risposta immediata di default
    return [
      const SafePlace(
        id: "1",
        name: "Centro Test",
        address: "Via Test 1",
        latitude: 45.0,
        longitude: 11.0,
        category: "Ospedale",
      )
    ];
  }
}