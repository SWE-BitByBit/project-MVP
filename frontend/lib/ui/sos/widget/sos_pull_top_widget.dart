import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/sos_view_model.dart';

class SosPullTopWidget extends StatefulWidget {
  const SosPullTopWidget({super.key});

  @override
  State<SosPullTopWidget> createState() => _SosPullTopWidgetState();
}

class _SosPullTopWidgetState extends State<SosPullTopWidget> {
  double _dragOffset = 0;
  // Aumentato un po' per dare più la sensazione di "tirare con forza"
  final double _triggerThreshold = 120.0;

  void _triggerSos() {
    context.read<SosViewModel>().sendAlert.run();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🚨 FRENO TIRATO: SOS INVIATO!', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calcola la percentuale di "tiro" (da 0.0 a 1.0)
    final progress = (_dragOffset / _triggerThreshold).clamp(0.0, 1.0);

    // L'opacità parte da 0.4 (molto trasparente e discreto) e arriva a 1.0 (rosso vivo)
    final currentOpacity = 0.4 + (0.6 * progress);

    return GestureDetector(
      onVerticalDragUpdate: (details) {
        setState(() {
          _dragOffset += details.primaryDelta!;
          if (_dragOffset < 0) _dragOffset = 0; // Impedisce di spingerlo in su
        });
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > _triggerThreshold) {
          _triggerSos();
        }
        setState(() {
          _dragOffset = 0; // Torna su come un elastico
        });
      },
      child: Transform.translate(
        offset: Offset(0, _dragOffset),
        child: Container(
          // Più stretto e corto a riposo (40x60)
          width: 40,
          height: 60 + (_dragOffset * 0.3), // Si allunga mentre tiri
          decoration: BoxDecoration(
            // Usa l'opacità dinamica che abbiamo calcolato!
            color: colorScheme.error.withValues(alpha: currentOpacity),
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
            // L'ombra compare solo quando inizi a tirare, facendolo sembrare "sollevato"
            boxShadow: progress > 0.1 ? [
              BoxShadow(
                  color: colorScheme.error.withValues(alpha: 0.5 * progress),
                  blurRadius: 10 * progress,
                  offset: const Offset(-2, 2)
              )
            ] : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Anche l'icona diventa più evidente mentre tiri
              Icon(
                Icons.keyboard_double_arrow_down,
                color: colorScheme.onError.withValues(alpha: currentOpacity > 0.6 ? 1.0 : 0.6),
                size: 20 + (4 * progress), // Si ingrandisce leggermente
              ),
              const SizedBox(height: 2),

              // Nascondiamo il testo a riposo per renderlo super pulito.
              // Compare solo quando tiri a metà strada!
              if (progress > 0.4)
                Text(
                    'SOS',
                    style: TextStyle(
                        color: colorScheme.onError,
                        fontWeight: FontWeight.bold,
                        fontSize: 10
                    )
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}