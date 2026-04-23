import 'package:flutter/material.dart';

/// Classe centralizzata per la gestione dei temi dell'applicazione.
class AppTheme {
  AppTheme._(); // Costruttore privato

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      // Impostiamo il Font di default se ne avete uno, altrimenti usa quello di sistema
      // fontFamily: 'Roboto',

      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        // Questo è il colore che verrà usato dai CircularProgressIndicator di default
        primary: Colors.teal.shade600,
        onPrimary: Colors.white,

        // Questo sostituisce il tuo "Colors.teal.shade200" per l'AppBar
        primaryContainer: Colors.teal.shade100,
        onPrimaryContainer: Colors.teal.shade900,

        // Questo sostituisce il "Colors.grey" per i bordi dei bottoni e i testi secondari
        outlineVariant: Colors.grey.shade400,
        surface: Colors.white,
        onSurface: Colors.black87,
        onSurfaceVariant: Colors.grey.shade700,

        // La palette per il tuo ErrorBannerWidget
        error: const Color(0xFFE74C3C), // Il vostro rosso acceso
        onError: Colors.white,
        errorContainer: const Color(0xFFFDEDEC), // Rosso sbiadito per lo sfondo dell'errore
      ),

      // Qui globalizziamo lo stile delle AppBar per non doverlo ripetere in ogni Screen
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal.shade200,
        centerTitle: true,
        foregroundColor: Colors.teal.shade900, // Colore del testo sull'AppBar
      ),
    );
  }
}