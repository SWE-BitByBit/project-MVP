import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

/// Widget che gestisce un elemento audio presente all'interno di una nota
class NoteAudioPlayerWidget extends StatefulWidget {
  final VoidCallback onDismiss;
  final String trackUrl;
  const NoteAudioPlayerWidget({
    super.key,
    required this.onDismiss,
    required this.trackUrl,
  });

  @override
  State<StatefulWidget> createState() => _NoteAudioPlayerWidget();
}

class _NoteAudioPlayerWidget extends State<NoteAudioPlayerWidget> {
  AudioPlayer player = AudioPlayer();

  /// Posizione attuale nella traccia audio
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  late StreamSubscription<Duration?> positionSub;
  late StreamSubscription<Duration?> durationSub;
  late StreamSubscription<PlayerState> stateSub;

  @override
  void initState() {
    player.setUrl(widget.trackUrl);

    /// Ascolta aggiornamenti nella posizione
    positionSub = player.positionStream.listen((p) {
      setState(() => position = p);
    });

    /// Ascolta aggiornamenti nella durata
    durationSub = player.durationStream.listen((d) {
      if (d != null) setState(() => duration = d);
    });

    /// Resetta il player quando arriva alla fine
    stateSub = player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _stopPlayer();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    positionSub.cancel();
    durationSub.cancel();
    stateSub.cancel();
    player.dispose();
    super.dispose();
  }

  /// Formatta un oggetto duration in una stringa della forma 00:00
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  /// Gestisce l'azione effettuata dal bottone play/pause
  void _handlePlayer() {
    if (player.playing) {
      player.pause();
    } else {
      player.play();
    }
  }

  /// Ferma la traccia audio e riporta il cursore all'inizio
  void _stopPlayer() {
    setState(() {
      position = Duration.zero;
    });
    player.pause();
    player.seek(Duration.zero);
  }

  /// Gestisce lo spostamento della testina sulla traccia audio
  void _handleSeek(double value) {
    player.seek(Duration(seconds: value.toInt()));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        textDirection: TextDirection.ltr,
        children: [
          Slider(
            min: 0.0,
            max: duration.inSeconds.toDouble(),
            value: position.inSeconds.toDouble(),
            onChanged: (value) => _handleSeek(value),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(player.playing ? Icons.pause : Icons.play_arrow),
                onPressed: () => _handlePlayer(),
              ),
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: () => _stopPlayer(),
              ),
              Expanded(
                child: Text(
                  "${_formatDuration(position)}/${_formatDuration(duration)}",
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
