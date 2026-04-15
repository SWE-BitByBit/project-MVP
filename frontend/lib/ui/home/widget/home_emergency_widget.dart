import 'package:flutter/material.dart';

/// Contenuto del pannello modale di emergenza rapida.
///
/// Visualizza il pannello SOS con il pulsante di emergenza principale.
/// Viene presentato all'interno di un [showModalBottomSheet] invocato da
/// [HomeActionsWidget] e comunica la chiusura tramite la callback [onDismiss].
class HomeEmergencyWidget extends StatelessWidget {
  /// Callback invocata quando il pannello viene chiuso (azione eseguita o annullata).
  final VoidCallback onDismiss;

  const HomeEmergencyWidget({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const Text(
            'Azioni Rapide',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                debugPrint("SOS PREMUTO DAL MENU NASCOSTO!");
                onDismiss();
              },
              icon: const Icon(
                Icons.warning,
                color: Colors.white,
                size: 28,
              ),
              label: const Text(
                'SOS',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
