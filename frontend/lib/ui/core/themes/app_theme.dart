import 'package:flutter/material.dart';

/// Classe centralizzata per la gestione dei temi dell'applicazione.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        primary: Colors.teal.shade600,
        onPrimary: Colors.white,
        primaryContainer: Colors.teal.shade100,
        onPrimaryContainer: Colors.teal.shade900,

        // Colori specifici per le bolle del Chatbot
        secondaryContainer: Colors.grey.shade200, // Bolla AI
        onSecondaryContainer: Colors.black87,

        tertiaryContainer: Colors.teal.shade500, // Bolla Utente
        onTertiaryContainer: Colors.white,

        outlineVariant: Colors.grey.shade400,
        surface: Colors.white,
        onSurface: Colors.black87,
        error: const Color(0xFFE74C3C),
        errorContainer: const Color(0xFFFDEDEC),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal.shade200,
        centerTitle: true,
        foregroundColor: Colors.teal.shade900,
        elevation: 0,
      ),
      // Definiamo uno stile standard per i testi dei messaggi
      textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
        labelSmall: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}