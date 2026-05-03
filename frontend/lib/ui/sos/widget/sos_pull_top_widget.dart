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

  final double _triggerThreshold = 550.0;

  Future<void> _triggerSos() async {
    final vm = context.read<SosViewModel>();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    try {
      await vm.sendAlert.runAsync();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),

              Text(
                '🚨 SOS INVIATO!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // ERRORE
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  ' INVIO FALLITO. Controlla la connessione.',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (_dragOffset / _triggerThreshold).clamp(0.0, 1.0);
    final currentOpacity = 0.4 + (0.6 * progress);
    final vm = context.read<SosViewModel>();
    return ValueListenableBuilder<bool>(
      valueListenable: vm.sendAlert.isRunning,
      builder: (context, isRunning, child) {
        vm.checkConnection();
        return GestureDetector(
          onVerticalDragUpdate: isRunning
              ? null
              : (details) {
                  setState(() {
                    _dragOffset += details.primaryDelta!;
                    if (_dragOffset < 0) _dragOffset = 0;
                  });
                },
          onVerticalDragEnd: isRunning
              ? null
              : (details) {
                  if (_dragOffset > _triggerThreshold) {
                    _triggerSos();
                  }
                  setState(() {
                    _dragOffset = 0;
                  });
                },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.translate(
                offset: Offset(0, _dragOffset),
                child: Container(
                  width: 40,
                  height: 60 + (_dragOffset * 0.3),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: currentOpacity),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(20),
                    ),
                    boxShadow: progress > 0.1
                        ? [
                            BoxShadow(
                              color: colorScheme.error.withValues(
                                alpha: 0.5 * progress,
                              ),
                              blurRadius: 10 * progress,
                              offset: const Offset(-2, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Se sta caricando, mostra lo spinner.
                      if (isRunning)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        )
                      else ...[
                        Icon(
                          Icons.keyboard_double_arrow_down,
                          color: colorScheme.onError.withValues(
                            alpha: currentOpacity > 0.6 ? 1.0 : 0.6,
                          ),
                          size: 20 + (2 * progress),
                        ),
                        const SizedBox(height: 2),
                        if (progress > 0.4)
                          Column(
                            children: [
                              Text(
                                'SOS',
                                style: TextStyle(
                                  color: colorScheme.onError,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                              if (!vm.isConnected)
                                Icon(
                                  Icons.signal_wifi_connected_no_internet_4,
                                  color: colorScheme.onError,
                                ),
                            ],
                          ),

                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
