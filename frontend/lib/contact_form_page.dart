import 'package:flutter/material.dart';

/// Rappresenta la schermata per creare un nuovo contatto o modificarne uno esistente.
///
/// Se [initialName] è valorizzato, la schermata si apre in modalità modifica,
/// pre-popolando i campi con i dati del contatto selezionato.
/// In assenza di valori iniziali, la schermata si apre in modalità creazione.
class ContactFormPage extends StatelessWidget {
  /// Nome e cognome iniziale del contatto, presente solo in modalità modifica.
  final String? initialName;

  /// Indirizzo email iniziale del contatto, presente solo in modalità modifica.
  final String? initialEmail;

  /// Numero di telefono iniziale del contatto, presente solo in modalità modifica.
  final String? initialPhone;

  const ContactFormPage({
    super.key,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
  });

  /// Costruisce l'interfaccia utente del modulo per la gestione di un contatto.
  ///
  /// Determina la modalità operativa in base alla presenza di [initialName]:
  /// se valorizzato, il titolo della pagina è "Modifica Contatto" e il pulsante
  /// riporta "Salva le modifiche"; altrimenti il titolo è "Nuovo Contatto" e
  /// il pulsante riporta "Salva nuovo contatto".
  /// Restituisce uno [Scaffold] con:
  /// - una [AppBar] con titolo dinamico;
  /// - un corpo con [SingleChildScrollView] contenente un'icona contestuale,
  ///   un sottotitolo descrittivo e tre [TextFormField] per nome, telefono ed email;
  /// - un [ElevatedButton] che, alla pressione, invoca la logica di salvataggio
  ///   e torna alla schermata precedente tramite [Navigator.pop].
  @override
  Widget build(BuildContext context) {
    final isEditing = initialName != null;
    final pageTitle = isEditing ? 'Modifica Contatto' : 'Nuovo Contatto';
    final buttonText = isEditing ? 'Salva le modifiche' : 'Salva nuovo contatto';

    return Scaffold(
      appBar: AppBar(
        title: Text(pageTitle),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                isEditing ? Icons.manage_accounts : Icons.person_add_alt_1,
                size: 80,
                color: Colors.teal.shade300,
              ),
              const SizedBox(height: 10),
              Text(
                isEditing
                    ? 'Aggiorna i dati del contatto'
                    : 'Aggiungi un contatto fidato',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                initialValue: initialName,
                decoration: InputDecoration(
                  labelText: 'Nome e Cognome',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: initialPhone,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Numero di Cellulare',
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                initialValue: initialEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Indirizzo Email',
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (isEditing) {
                    print("Sto AGGIORNANDO i dati sul backend...");
                  } else {
                    print("Sto CREANDO un nuovo contatto sul backend...");
                  }
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
