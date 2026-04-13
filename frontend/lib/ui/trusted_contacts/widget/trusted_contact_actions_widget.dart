import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/trusted_contact_view_model.dart';
import 'trusted_contact_form_widget.dart';

/// Raggruppa le azioni specifiche per la gestione dei contatti fidati.
///
/// Contiene il pulsante per aggiungere un nuovo contatto, che apre
/// [TrustedContactFormWidget] in un bottom sheet. Comunica le intenzioni
/// dell'utente direttamente al [TrustedContactViewModel].
class TrustedContactActionsWidget extends StatelessWidget {
  const TrustedContactActionsWidget({super.key});

  /// Apre il [TrustedContactFormWidget] in un pannello modale a scorrimento dal basso.
  ///
  /// Il pannello è ancorato al [context] corrente e viene chiuso automaticamente
  /// al termine dell'operazione di creazione tramite la callback [Navigator.pop].
  void _openAddContactForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        // Propaga il ChangeNotifierProvider nel contesto del bottom sheet
        return ChangeNotifierProvider.value(
          value: context.read<TrustedContactViewModel>(),
          child: TrustedContactFormWidget(
            onDismiss: () => Navigator.pop(sheetContext),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _openAddContactForm(context),
      backgroundColor: Colors.teal,
      tooltip: 'Aggiungi contatto fidato',
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }
}
