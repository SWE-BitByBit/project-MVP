import 'package:flutter/material.dart';
import '../../../../domain/models/safeplace/safe_place_enums.dart';

/// Estensione esclusiva per la UI: aggiunge logica visiva all'Enum di dominio
/// senza inquinare il Domain Layer con classi di Flutter come [Color] o [IconData].
extension SafePlaceCategoryUI on SafePlaceCategory {

  /// Restituisce il colore semantico appropriato pescando dal Theme.
  Color getColor(ColorScheme colorScheme) {
    switch (this) {
      case SafePlaceCategory.hospital:
        return colorScheme.error;
      case SafePlaceCategory.police:
        return colorScheme.primary;
      case SafePlaceCategory.pharmacy:
        return colorScheme.tertiaryContainer;
      case SafePlaceCategory.emergencyShelter:
        return colorScheme.outline;
      case SafePlaceCategory.other:
        return colorScheme.onSurfaceVariant;
    }
  }

  /// Restituisce l'icona materiale appropriata per la mappa.
  IconData get icon {
    switch (this) {
      case SafePlaceCategory.hospital: return Icons.local_hospital;
      case SafePlaceCategory.police: return Icons.local_police;
      case SafePlaceCategory.pharmacy: return Icons.local_pharmacy;
      case SafePlaceCategory.emergencyShelter: return Icons.night_shelter;
      case SafePlaceCategory.other: return Icons.location_on;
    }
  }
}