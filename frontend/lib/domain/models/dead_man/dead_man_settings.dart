/// Modello di dominio che rappresenta la configurazione del Dead Man's Switch.
///
/// Questa classe è rigorosamente IMMUTABILE. Per modificare un valore
/// (ad esempio durante la compilazione del form), utilizzare il metodo [copyWith].
class DeadManSettings {
  /// Indica se il timer è attualmente armato e in esecuzione sul server.
  final bool isActive;

  /// Minuti di inattività prima che l'app invii la notifica di "Check-in" (Avvertimento).
  final int firstInactivityTimer;

  /// Minuti a disposizione dopo l'avvertimento prima che scatti l'allarme vero e proprio.
  final int secondInactivityTimer;

  /// Oggetto del messaggio inviato ai contatti fidati in caso di mancato check-in.
  final String messageSubject;

  /// Corpo del messaggio inviato ai contatti fidati (es. "Aiuto, non rispondo da X ore...").
  final String messageBody;

  const DeadManSettings({
    this.isActive = false,
    this.firstInactivityTimer = 5, // Default 1 ora
    this.secondInactivityTimer = 2, // Default 15 minuti per rispondere
    this.messageSubject = 'Emergenza: Mancato Check-in',
    this.messageBody = 'Non ho confermato il mio stato di sicurezza sull\'app. Per favore controlla la mia ultima posizione.',
  });

  /// Crea una copia esatta di questo oggetto, sovrascrivendo solo i campi specificati.
  /// Fondamentale per gestire lo "Stato Bozza" nel ViewModel prima del salvataggio.
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