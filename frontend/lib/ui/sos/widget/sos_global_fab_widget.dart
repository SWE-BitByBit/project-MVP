import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/sos_view_model.dart';

class SosGlobalFab extends StatelessWidget {
  const SosGlobalFab({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Usiamo un Consumer per farlo apparire/sparire se necessario
    return Consumer<SosViewModel>(
      builder: (context, vm, child) {
        return Positioned(
          left: 16,
          bottom: 110,
          child: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.8,
              child: GestureDetector(
                onLongPress: () {
                  context.read<SosViewModel>().sendAlert.run();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('🚨 SOS INVIATO!'),
                      backgroundColor: colorScheme.error,
                    ),
                  );
                },
                child: FloatingActionButton.small(
                  heroTag: 'global_sos_button',
                  backgroundColor: colorScheme.error,
                  foregroundColor: colorScheme.onError,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tieni premuto per SOS'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                  child: const Icon(Icons.emergency, size: 20),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}