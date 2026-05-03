import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/trusted_contact_view_model.dart';
import 'trusted_contact_form_widget.dart';

/// Raggruppa le azioni specifiche per la gestione dei contatti fidati.
class TrustedContactActionsWidget extends StatelessWidget {
  const TrustedContactActionsWidget({super.key});

  /// Apre il [TrustedContactFormWidget] in un pannello modale.
  void _openAddContactForm(BuildContext context) {
    final viewModel = context.read<TrustedContactViewModel>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return ChangeNotifierProvider.value(
          value: viewModel,
          child: Padding(
            // Previene che la tastiera copra i campi di testo
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: TrustedContactFormWidget(
              onDismiss: () => Navigator.pop(sheetContext),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FloatingActionButton(
      onPressed: () => _openAddContactForm(context),
      backgroundColor: theme.colorScheme.primary,
      foregroundColor: theme.colorScheme.onPrimary,
      tooltip: 'Aggiungi contatto fidato',
      child: const Icon(Icons.add, size: 28),
    );
  }
}