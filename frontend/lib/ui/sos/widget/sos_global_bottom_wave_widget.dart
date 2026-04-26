import 'dart:async'; // Aggiungi questo import in cima per il Timer!
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/sos_view_model.dart';

class SosGlobalBottomWave extends StatefulWidget {
  const SosGlobalBottomWave({super.key});

  @override
  State<SosGlobalBottomWave> createState() => _SosGlobalBottomWaveState();
}

class _SosGlobalBottomWaveState extends State<SosGlobalBottomWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _delayTimer; // Il nostro timer per il ritardo

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _controller.addListener(() {
      setState(() {});
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

  void _onPointerDown() {
    // 1. Appena tocchi, avviamo un timer di 500ms
    _delayTimer?.cancel(); // Sicurezza: cancelliamo vecchi timer se esistono
    _delayTimer = Timer(const Duration(milliseconds: 500), () {
      // 2. Se dopo mezzo secondo il dito è ancora lì, parte l'animazione!
      _controller.forward();
    });
  }

  void _onPointerCancelOrUp() {
    // 3. Se togli il dito, annulliamo subito il timer!
    _delayTimer?.cancel();
    // 4. E facciamo rientrare l'animazione (nel caso fosse già partita)
    _controller.reverse();
  }

  @override
  void dispose() {
    _delayTimer?.cancel(); // Pulizia fondamentale
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [

        // 1. L'ANIMAZIONE
        if (_controller.value > 0)
          Positioned(
            bottom: 0, left: 0, right: 0,
            height: 130,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 2.0 - (_controller.value * 1.5),
                    colors: [
                      Colors.transparent,
                      colorScheme.error.withValues(alpha: 0.6),
                    ],
                    stops: const [0.1, 1.5],
                  ),
                ),
              ),
            ),
          ),

        // 2. L'AREA DI TOCCO
        Listener(
          behavior: HitTestBehavior.translucent,
          // Agganciato ai nostri nuovi metodi con il Timer
          onPointerDown: (_) => _onPointerDown(),
          onPointerUp: (_) => _onPointerCancelOrUp(),
          onPointerCancel: (_) => _onPointerCancelOrUp(),
          child: SizedBox(
            width: 80,
            height: 130,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 80.0),
                child: Container(
                  width: 24,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
        ),

      ],
    );
  }
}