import 'package:flutter/material.dart';
import 'home_emergency_widget.dart';

/// Raggruppa le azioni rapide della schermata principale.
///
/// Contiene il pulsante che apre il pannello di emergenza [HomeEmergencyWidget]
/// tramite un bottom sheet modale. Comunica le intenzioni dell'utente
/// verso le funzionalità di emergenza disponibili.
class HomeActionsWidget extends StatelessWidget {
  const HomeActionsWidget({super.key});

  /// Apre il [HomeEmergencyWidget] in un pannello modale a scorrimento dal basso.
  ///
  /// Il pannello è ancorato al [context] corrente e viene chiuso automaticamente
  /// tramite la callback [Navigator.pop] passata a [HomeEmergencyWidget].
  void _openEmergencyPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return HomeEmergencyWidget(
          onDismiss: () => Navigator.pop(sheetContext),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FloatingActionButton(
        onPressed: () => _openEmergencyPanel(context),
        backgroundColor: Colors.teal.shade50,
        elevation: 0,
        tooltip: 'Azioni rapide di emergenza',
        child: Icon(
          Icons.keyboard_arrow_up,
          color: Colors.teal.shade800,
          size: 30,
        ),
      ),
    );
  }
}
