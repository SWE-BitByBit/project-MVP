/// Modello di dominio che rappresenta la configurazione del Dead Man's Switch.
///
/// Questa classe è rigorosamente IMMUTABILE. Per modificare un valore utilizzare il metodo [copyWith].
class DeadManSettings {
  /// Indica se il timer è attivo o meno.
  final bool isActive;

  /// Minuti di inattività prima che l'app invii la notifica di "Check-in" (Avvertimento).
  final int firstInactivityTimer;

  /// Minuti a disposizione dopo l'avvertimento prima che scatti l'allarme vero e proprio.
  final int secondInactivityTimer;

  /// Oggetto del messaggio inviato ai contatti fidati
  final String messageSubject;

  /// Corpo del messaggio inviato ai contatti fidati
  final String messageBody;

  const DeadManSettings({
    this.isActive = false,
    this.firstInactivityTimer = 5,
    this.secondInactivityTimer = 2,
    this.messageSubject = 'Emergenza: Mancato Check-in',
    this.messageBody = 'Non ho confermato il mio stato di sicurezza sull\'app. Per favore controlla la mia ultima posizione.',
  });

  /// Crea una copia esatta di questo oggetto, sovrascrivendo solo i campi specificati.
  DeadManSettings copyWith({
    bool? isActive,
    int? firstInactivityTimer,
    int? secondInactivityTimer,
    String? messageSubject,
    String? messageBody,
  }) {
    return DeadManSettings(
      isActive: isActive ?? this.isActive,
      firstInactivityTimer: firstInactivityTimer ?? this.firstInactivityTimer,
      secondInactivityTimer: secondInactivityTimer ?? this.secondInactivityTimer,
      messageSubject: messageSubject ?? this.messageSubject,
      messageBody: messageBody ?? this.messageBody,
    );
  }
}