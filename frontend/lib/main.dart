import 'package:flutter/material.dart';
import '/ui/chat/widget/chat_screen.dart';

/// Punto di ingresso principale dell'applicazione.
///
/// Inizializza e avvia l'applicazione Flutter istanziando [MainApp]
/// come widget radice tramite [runApp].
void main() {
  runApp(const MainApp());
}

/// Classe principale che configura il tema e la navigazione dell'applicazione.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  /// Costruisce il widget radice dell'applicazione.
  ///
  /// Restituisce un [MaterialApp] con il tema globale basato sul colore
  /// primario teal e imposta [HomePage] come schermata iniziale.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'L\'App che Protegge e Trasforma',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}
