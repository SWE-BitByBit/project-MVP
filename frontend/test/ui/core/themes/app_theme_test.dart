import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

// Sostituisci con il path corretto al tuo file AppTheme
import 'package:mvp_app_protegge_e_trasforma/ui/core/themes/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Evitiamo richieste di rete durante i test.
    // Questo causerà un'eccezione asincrona da parte di GoogleFonts.
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  // Funzione di utilità per eseguire i test ignorando il crash asincrono
  // di google_fonts senza nascondere i reali fallimenti dei test.
  Future<void> runWithIgnoredFontsError(FutureOr<void> Function() testBody) async {
    await runZonedGuarded(
          () async {
        await testBody();
        // Diamo un tick al loop asincrono per permettere all'eccezione
        // di Google Fonts di emergere in background ed essere catturata
        await Future.delayed(Duration.zero);
      },
          (error, stack) {
        // Ignoriamo SOLO l'eccezione attesa del font mancante
        if (error.toString().contains('GoogleFonts.config.allowRuntimeFetching is false')) {
          return;
        }
        // Rilanciamo gli errori reali (inclusi i fallimenti degli expect)
        throw error;
      },
    );
  }

  group('AppTheme - Generazione Tema', () {
    test('lightTheme restituisce un ThemeData configurato correttamente e statico', () async {
      await runWithIgnoredFontsError(() {
        // Act
        final theme = AppTheme.lightTheme;

        // Assert - Check configurazioni base
        expect(theme.useMaterial3, isTrue);

        // Assert - Color Scheme
        expect(theme.colorScheme.primary, Colors.teal.shade600);
        expect(theme.colorScheme.error, const Color(0xFFE74C3C));
        expect(theme.colorScheme.surface, Colors.white);

        // Assert - Componenti Statici
        expect(theme.appBarTheme.backgroundColor, Colors.teal.shade200);
        expect(theme.appBarTheme.centerTitle, isTrue);
        expect(theme.floatingActionButtonTheme.backgroundColor, Colors.white);
        expect(theme.bottomSheetTheme.backgroundColor, Colors.white);
        expect(theme.chipTheme.backgroundColor, Colors.teal.shade100);
        expect(theme.snackBarTheme.backgroundColor, const Color(0xFFE74C3C));

        // Assert - Slider Theme
        expect(theme.sliderTheme.activeTrackColor, Colors.teal.shade600);
        expect(theme.sliderTheme.thumbColor, Colors.teal.shade600);
      });
    });
  });

  group('AppTheme - Risoluzione degli stati dinamici (WidgetState)', () {
    test('switchTheme risolve correttamente i colori per gli stati selected e unselected', () async {
      await runWithIgnoredFontsError(() {
        // Arrange
        final theme = AppTheme.lightTheme;
        final switchTheme = theme.switchTheme;

        // Act & Assert - Selected
        expect(switchTheme.thumbColor?.resolve({WidgetState.selected}), Colors.teal.shade600);
        expect(switchTheme.trackColor?.resolve({WidgetState.selected}), Colors.teal.shade200);

        // Act & Assert - Unselected (Nessuno stato)
        expect(switchTheme.thumbColor?.resolve({}), Colors.white);
        expect(switchTheme.trackColor?.resolve({}), Colors.grey.shade300);
      });
    });

    test('navigationBarTheme risolve correttamente stili di testo per gli stati selected e unselected', () async {
      await runWithIgnoredFontsError(() {
        // Arrange
        final theme = AppTheme.lightTheme;
        final navTheme = theme.navigationBarTheme;

        // Act & Assert - Selected
        final selectedTextStyle = navTheme.labelTextStyle?.resolve({WidgetState.selected});
        expect(selectedTextStyle?.color, Colors.black);
        expect(selectedTextStyle?.fontWeight, FontWeight.w600);
        expect(selectedTextStyle?.fontSize, 13);

        // Act & Assert - Unselected
        final unselectedTextStyle = navTheme.labelTextStyle?.resolve({});
        expect(unselectedTextStyle?.color, Colors.teal.shade800);
        expect(unselectedTextStyle?.fontWeight, FontWeight.w400);
        expect(unselectedTextStyle?.fontSize, 12);
      });
    });

    test('navigationBarTheme risolve correttamente le icone per gli stati selected e unselected', () async {
      await runWithIgnoredFontsError(() {
        // Arrange
        final theme = AppTheme.lightTheme;
        final navTheme = theme.navigationBarTheme;

        // Act & Assert - Selected
        final selectedIconTheme = navTheme.iconTheme?.resolve({WidgetState.selected});
        expect(selectedIconTheme?.color, Colors.black);
        expect(selectedIconTheme?.size, 28);

        // Act & Assert - Unselected
        final unselectedIconTheme = navTheme.iconTheme?.resolve({});
        expect(unselectedIconTheme?.color, Colors.teal.shade800);
        expect(unselectedIconTheme?.size, 24);
      });
    });
  });
}