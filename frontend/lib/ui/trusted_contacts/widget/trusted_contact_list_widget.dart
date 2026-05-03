import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_model/trusted_contact_view_model.dart';
import '../../../domain/models/trusted_contact/trusted_contact.dart';
import 'trusted_contact_form_widget.dart';

/// Visualizza l'elenco dei contatti fidati salvati.
///
/// Implementa il pattern Observer tramite il widget [Consumer], che ascolta
/// il [TrustedContactViewModel] e ricostruisce la lista ad ogni notifica di cambiamento.
class TrustedContactListWidget extends StatelessWidget {
  const TrustedContactListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Usiamo il Consumer come richiesto dall'UML
    return Consumer<TrustedContactViewModel>(
      builder: (context, viewModel, child) {
        // STATO: Lista Vuota
        if (viewModel.contacts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 64, color: theme.disabledColor),
                const SizedBox(height: 16),
                Text(
                  'Nessun contatto fidato',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Aggiungi un contatto fidato\ncon il pulsante qui sotto.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        }

        // STATO: Lista Popolata
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.contacts.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final contact = viewModel.contacts[index];

            // Estrazione sicura dell'iniziale
            final String initial = contact.name.isNotEmpty
                ? contact.name[0].toUpperCase()
                : '?';

            return ListTile(
              onTap: () => _openEditForm(context, viewModel, contact),
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  initial,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                contact.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text('${contact.email}\n${contact.phoneNumber}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                onPressed: () => _showDeleteConfirmation(
                  context,
                  viewModel,
                  contact.id,
                  contact.name,
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Apre il modulo di modifica per un contatto esistente.
  void _openEditForm(
    BuildContext context,
    TrustedContactViewModel viewModel,
    TrustedContact contact,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        // Usiamo .value perché il ViewModel esiste già ed è gestito dal Provider padre
        viewModel.clearInputErrors();
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: TrustedContactFormWidget(
              initialContact: contact,
              onDismiss: () {
                Navigator.pop(sheetContext);
              },
            ),
          ),
        );
      },
    );
  }

  /// Mostra un dialogo di conferma prima dell'eliminazione ottimistica.
  void _showDeleteConfirmation(
    BuildContext context,
    TrustedContactViewModel viewModel,
    String contactId,
    String contactName,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Elimina Contatto'),
          content: Text('Rimuovere $contactName dai contatti fidati?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Annulla', style: TextStyle(color: theme.hintColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                // Il comando attiva la logica nel ViewModel/Repo
                viewModel.deleteContact.runAsync(contactId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Elimina'),
            ),
          ],
        );
      },
    );
  }
}
