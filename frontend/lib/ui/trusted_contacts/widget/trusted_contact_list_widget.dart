import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/trusted_contact_view_model.dart';

/// Visualizza l'elenco dei contatti fidati salvati.
///
/// Implementa il pattern Consumer tramite [context.watch] per osservare
/// il [TrustedContactViewModel] e reagire dinamicamente ai cambiamenti di stato,
/// aggiornando l'interfaccia grafica ad ogni notifica.
class TrustedContactListWidget extends StatelessWidget {
  const TrustedContactListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TrustedContactViewModel>();

    if (viewModel.isLoading && viewModel.contacts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group_off, size: 64, color: Colors.teal.shade200),
            const SizedBox(height: 16),
            Text(
              'Nessun contatto fidato',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aggiungi una persona di fiducia\ncon il pulsante qui sotto.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.contacts.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final contact = viewModel.contacts[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.teal.shade100,
            child: Text(
              contact.getName()[0].toUpperCase(),
              style: TextStyle(
                color: Colors.teal.shade900,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            contact.getName(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            '${contact.getEmail()}\n${contact.getPhone()}',
          ),
          isThreeLine: true,
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(
              context,
              viewModel,
              contact.getId(),
              contact.getName(),
            ),
          ),
        );
      },
    );
  }

  /// Mostra un dialogo di conferma prima di eliminare il contatto.
  ///
  /// Visualizza un [AlertDialog] con il nome del contatto da rimuovere.
  /// Alla conferma, invoca [TrustedContactViewModel.deleteContact] con l'[contactId] specificato.
  void _showDeleteConfirmation(
    BuildContext context,
    TrustedContactViewModel viewModel,
    String contactId,
    String contactName,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Elimina Contatto'),
          content: Text(
            'Sei sicuro di voler rimuovere $contactName dai tuoi contatti fidati? '
            'Questa azione non può essere annullata.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Annulla',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                viewModel.deleteContact(contactId);
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
}
