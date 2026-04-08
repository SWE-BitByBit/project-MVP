import 'package:flutter/material.dart';
import 'contact_form_page.dart';

/// Rappresenta la schermata per la gestione dei contatti fidati dell'utente.
class TrustedContactsPage extends StatelessWidget {
  const TrustedContactsPage({super.key});

  /// Mostra una finestra di dialogo di conferma prima di eliminare un contatto.
  ///
  /// Visualizza un [AlertDialog] con il nome del contatto da rimuovere e due azioni:
  /// - un [TextButton] per annullare l'operazione e chiudere il dialogo;
  /// - un [ElevatedButton] rosso per confermare l'eliminazione definitiva.
  /// Richiede il [context] corrente e il [contactName] del contatto selezionato.
  void _showDeleteConfirmation(BuildContext context, String contactName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Elimina Contatto'),
          content: Text(
            'Sei sicuro di voler rimuovere $contactName dai tuoi contatti fidati? Questa azione non può essere annullata.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Annulla',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                print("Eliminazione CONFERMATA per: $contactName");
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Elimina',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Costruisce l'interfaccia utente della schermata dei contatti fidati.
  ///
  /// Restituisce uno [Scaffold] composto da:
  /// - una [AppBar] con il titolo "Contatti Fidati";
  /// - un corpo con una [ListView.separated] che mostra un [ListTile] per ogni contatto,
  ///   con avatar iniziale, nome, email, telefono, pulsante di eliminazione che invoca
  ///   [_showDeleteConfirmation] e navigazione a [ContactFormPage] in modalità modifica al tocco;
  /// - un [FloatingActionButton] che naviga a [ContactFormPage] in modalità creazione.
  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> mockContacts = [
      {
        'name': 'Mario Rossi',
        'email': 'mario.rossi@email.com',
        'phone': '+39 333 1234567',
      },
      {
        'name': 'Laura Bianchi',
        'email': 'laura.b@email.com',
        'phone': '+39 345 9876543',
      },
      {
        'name': 'Giulia Verdi (Sorella)',
        'email': 'giulia.verdi@email.com',
        'phone': '+39 399 5556667',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatti Fidati'),
        backgroundColor: Colors.teal.shade200,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: mockContacts.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final contact = mockContacts[index];

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.teal.shade100,
                child: Text(
                  contact['name']![0],
                  style: TextStyle(
                    color: Colors.teal.shade900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                contact['name']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text('${contact['email']}\n${contact['phone']}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () {
                  _showDeleteConfirmation(context, contact['name']!);
                },
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ContactFormPage(
                      initialName: contact['name'],
                      initialEmail: contact['email'],
                      initialPhone: contact['phone'],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ContactFormPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
