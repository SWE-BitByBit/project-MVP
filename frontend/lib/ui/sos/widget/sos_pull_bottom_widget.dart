import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/sos_view_model.dart';

class SosPullBottomWidget extends StatefulWidget {
  const SosPullBottomWidget({super.key});

  @override
  State<SosPullBottomWidget> createState() => _SosPullBottomWidgetState();
}

class _SosPullBottomWidgetState extends State<SosPullBottomWidget> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _isOpen = !_isOpen),
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! < -7 && !_isOpen) setState(() => _isOpen = true);
        if (details.primaryDelta! > 7 && _isOpen) setState(() => _isOpen = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.fastOutSlowIn,
        // Aumentiamo leggermente l'altezza da chiusa a 50 per stare larghi
        height: _isOpen ? 180 : 50,
        width: double.infinity,
        decoration: BoxDecoration(
          color: _isOpen ? colorScheme.errorContainer : colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: const Offset(0, -2),
            )
          ],
        ),
        child: Column(
          // Centriamo il contenuto verticalmente per evitare scontri con i bordi
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // LA MANIGLIA (Margini ridotti per salvare spazio)
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              decoration: BoxDecoration(
                color: _isOpen ? colorScheme.error : colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            if (!_isOpen)
            // Testo molto piccolo e "stretto" per evitare overflow
              Text(
                  "SCORRI PER SOS",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.error,
                      letterSpacing: 1.2
                  )
              ),

            if (_isOpen)
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: colorScheme.error, size: 40),
                    const SizedBox(height: 8),
                    FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: colorScheme.error),
                      onPressed: () {
                        context.read<SosViewModel>().sendAlert.run();
                        setState(() => _isOpen = false);
                      },
                      child: const Text("CONFERMA SOS"),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}