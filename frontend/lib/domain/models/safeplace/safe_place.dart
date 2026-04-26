/// Rappresenta un luogo sicuro all'interno del dominio dell'applicazione.
class SafePlace {
  /// L'identificatore univoco del luogo sicuro.
  final String id;

  /// Il nome del luogo sicuro.
  final String name;

  /// L'indirizzo fisico del luogo sicuro.
  final String address;

  /// La coordinata di latitudine geografica.
  final double latitude;

  /// La coordinata di longitudine geografica.
  final double longitude;

  /// La categoria a cui appartiene il luogo sicuro.
  final String category;

  /// Crea un'istanza immutabile di [SafePlace].
  const SafePlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.category,
  });
}