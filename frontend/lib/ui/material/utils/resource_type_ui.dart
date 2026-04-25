import 'package:flutter/material.dart';
import '../../../domain/models/material/resource_type.dart';

/// Estensione UI per aggiungere icone tematiche alle categorie di risorse.
extension ResourceTypeUI on ResourceType {
  /// Restituisce l'icona appropriata per il tipo di materiale.
  IconData get icon {
    switch (this) {
      case ResourceType.community:
        return Icons.people_alt_outlined; // Icona per associazioni
      case ResourceType.law:
        return Icons.gavel; // Icona martelletto per le leggi
      case ResourceType.article:
        return Icons.article_outlined; // Icona documento per le guide
    }
  }

  /// Restituisce un colore semantico pescando dal tema dell'app.
  Color getColor(ColorScheme scheme) {
    switch (this) {
      case ResourceType.community:
        return scheme.tertiaryContainer;
      case ResourceType.law:
        return scheme.primary;
      case ResourceType.article:
        return scheme.outline;
    }
  }
}