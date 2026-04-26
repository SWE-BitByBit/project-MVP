import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/sos_view_model.dart';

class SosHomeIconWidget extends StatefulWidget {
  final bool isSelected;
  const SosHomeIconWidget({super.key, required this.isSelected});

  @override
  State<SosHomeIconWidget> createState() => _SosHomeIconWidgetState();
}

class _SosHomeIconWidgetState extends State<SosHomeIconWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 1.5 secondi per il completamento dell'allarme
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));

    _controller.addListener(() {
      setState(() {}); // Aggiorna per animare l'onda sulla barra
      if (_controller.status == AnimationStatus.completed) {
        _triggerSos();
        _controller.reset();
      }
    });
  }

  void _triggerSos() {
    context.read<SosViewModel>().sendAlert.run();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('🚨 ALLARME SOS INVIATO!', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // Usiamo Listener per non farci rubare il tocco dalla NavBar
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => _controller.forward(),
      onPointerUp: (_) => _controller.reverse(),
      onPointerCancel: (_) => _controller.reverse(),

      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none, // Permette all'effetto di uscire dai bordi
        children: [

          // 1. L'EFFETTO "ONDA LATERALE" NELLA NAVBAR
          if (_controller.value > 0)
            Positioned(
              // Espandiamo il widget su tutta la larghezza della barra
              left: -screenWidth,
              right: -screenWidth,
              bottom: -40, // Lo abbassiamo e alziamo per coprire bene
              top: -40,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    // --- IL NUOVO GRADIENTE RADIALE ---
                    gradient: RadialGradient(
                      center: Alignment.center, // Centrato sotto l'icona
                      // Il raggio parte ENORME (coprendo i lati) e si restringe verso il centro
                      radius: 2.0 - (_controller.value * 1.8),
                      colors: [
                        Colors.transparent, // Il centro è pulito
                        colorScheme.error.withValues(alpha: 0.6), // I bordi sono rossi
                      ],
                      stops: const [
                        0.1, // Il centro pulito è stretto
                        1.0, // Il rosso è ai bordi
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // 2. L'ICONA HOME E L'ANELLO DI CONFERMA
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    widget.isSelected ? Icons.home : Icons.home_outlined,
                    size: 28,
                    // Se l'allarme è quasi pieno, cambiamo colore all'icona per contrasto
                    color: _controller.value > 0.7 ? colorScheme.onError : null,
                  ),

                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}