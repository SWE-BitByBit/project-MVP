import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/sos_view_model.dart';

class SosFloatingButton extends StatelessWidget {
  const SosFloatingButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: 0.90,
      child: GestureDetector(
        onLongPress: () {
          context.read<SosViewModel>().sendAlert.run();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '🚨 ALLARME SOS INVIATO!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: colorScheme.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: FloatingActionButton.extended(
          heroTag: 'sos_fab_classic',
          backgroundColor: colorScheme.error,
          foregroundColor: colorScheme.onError,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Tieni premuto per inviare SOS'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.emergency, size: 28),
          label: const Text(
            'SOS',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ),
    );
  }
}