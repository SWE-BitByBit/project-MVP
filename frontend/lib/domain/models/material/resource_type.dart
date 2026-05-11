/// Definisce le tipologie di materiale informativo disponibili nell'applicazione.
enum ResourceType {
  /// collegamento a gruppi di supporto.
  community,
  /// collegamento a normative e leggi.
  law,
  /// collegamento ad articoli, guide e risorse informative generiche.
  article;

  /// Utility per ottenere una stringa leggibile nella lingua dell'utente.
  String get displayName {
    switch (this) {
      case ResourceType.community:
        return 'Community e Associazioni';
      case ResourceType.law:
        return 'Normative';
      case ResourceType.article:
        return 'Articoli e Guide';
    }
  }

  /// Converte la stringa [value] proveniente dal DB nell'enumerativo corrispondente.
  static ResourceType fromString(String? value) {
    final normalized = value?.toLowerCase().trim();
    switch (normalized) {
      case 'community':
      case 'associazione':
      case 'gruppo':
        return ResourceType.community;
      case 'law':
      case 'legge':
      case 'normativa':
        return ResourceType.law;
      case 'article':
      case 'articolo':
      case 'guida':
        return ResourceType.article;
      default:
      // Se il backend manda qualcosa di sconosciuto, fallback sul tipo più generico
        return ResourceType.article;
    }
  }

  /// Restituisce la rappresentazione stringa dell'Enum per l'invio al server (se necessario).
  String toJson() => name;
}