/// Definisce le categorie tipizzate dei luoghi sicuri.
enum SafePlaceCategory {
  hospital,
  police,
  pharmacy,
  emergencyShelter,
  other;

  /// Utility per ottenere una stringa leggibile (opzionale, utile per la UI).
  String get displayName {
    switch (this) {
      case SafePlaceCategory.hospital: return 'Ospedale';
      case SafePlaceCategory.police: return 'Polizia';
      case SafePlaceCategory.pharmacy: return 'Farmacia';
      case SafePlaceCategory.emergencyShelter: return 'Rifugio';
      case SafePlaceCategory.other: return 'Altro';
    }
  }
}


