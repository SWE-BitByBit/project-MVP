import 'package:flutter/material.dart';

/// Classe centralizzata per la gestione dei temi dell'applicazione.
class AppTheme {
  // Costruttore privato per impedire l'istanziamento di questa classe utility
  AppTheme._();

  static ThemeData get lightTheme {
    // Definiamo i colori base in variabili locali per riutilizzarli agevolmente
    // nei temi dei componenti qui sotto.
    final primaryColor = Colors.teal.shade600;
    final primaryLight = Colors.teal.shade200;
    final primaryDark = Colors.teal.shade900;
    final surfaceColor = Colors.white;
    const errorColor = Color(0xFFE74C3C);

    return ThemeData(
      useMaterial3: true,

      // --- COLOR SCHEME (Palette Semantica) ---
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        primary: primaryColor,
        onPrimary: Colors.white,
        primaryContainer: Colors.teal.shade100,
        onPrimaryContainer: primaryDark,

        // Colori Chatbot (Mantenuti dalla tua versione)
        secondaryContainer: Colors.grey.shade200,
        onSecondaryContainer: Colors.black87,
        tertiaryContainer: Colors.teal.shade500,
        onTertiaryContainer: Colors.white,

        // Superfici (Usati per Sfondi Mappa, BottomSheet, Card)
        surface: surfaceColor,
        onSurface: Colors.black87,
        surfaceContainerHighest: Colors.grey.shade100, // Sfondi secondari
        onSurfaceVariant: Colors.grey.shade700, // Testo secondario (es. Indirizzi)

        // Errori (Usati per SnackBar, ErrorIndicator, Pin Mappa Ospedali)
        error: errorColor,
        onError: Colors.white,
        errorContainer: const Color(0xFFFDEDEC),
        onErrorContainer: const Color(0xFFC0392B),

        // Utilità
        outline: Colors.grey.shade500,
        outlineVariant: Colors.grey.shade400,
        shadow: Colors.black, // Usato per le ombre dei pin della mappa
      ),

      // --- TEXT THEMES (Tipografia) ---
      textTheme: const TextTheme(
        // Titoli grandi (es. Nome del luogo nel BottomSheet)
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
        // Testo principale e indirizzi (es. Indirizzo nel BottomSheet)
        bodyLarge: TextStyle(fontSize: 16, color: Colors.black87),
        // Testo standard (es. Messaggi chat)
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black87),
        // Testi piccoli o label (es. Orari chat, label sotto i bottoni)
        labelSmall: TextStyle(fontSize: 12, color: Colors.grey),
      ),

      // --- COMPONENT THEMES (Stili specifici dei Widget) ---

      appBarTheme: AppBarTheme(
        backgroundColor: primaryLight,
        centerTitle: true,
        foregroundColor: primaryDark,
        elevation: 0,
        // Su M3, lo scroll cambia il colore dell'AppBar. Questo lo previene:
        surfaceTintColor: Colors.transparent,
      ),

      // Stile globale per i bottoni flottanti (FAB)
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: surfaceColor,
        foregroundColor: primaryColor, // Il colore delle icone dentro il FAB
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Stile globale per i BottomSheet (Quello dei dettagli dei luoghi)
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Stile globale per i Chip (Usati per le categorie dei luoghi)
      chipTheme: ChipThemeData(
        backgroundColor: Colors.teal.shade100,
        labelStyle: TextStyle(color: primaryDark, fontWeight: FontWeight.w500),
        side: BorderSide.none, // Togliamo il bordino di default
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Stile globale per le SnackBar (Usate per gli errori non bloccanti)
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: errorColor,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}