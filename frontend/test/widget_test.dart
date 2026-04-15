import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/main.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/core/widgets/dashboard_button_widget.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/widget/home_screen.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/trusted_contacts/widget/trusted_contacts_screen.dart';

/// Suite di smoke test dell'applicazione.
///
/// Questo file costituisce il punto di partenza per la suite di test del frontend.
/// I test effettivi dei singoli widget e delle funzionalità business dovranno essere
/// scritti dal verificatore incaricato.
///
/// Convenzioni da seguire nell'espansione di questa suite:
/// - un file di test per ogni widget o pagina da verificare;
/// - utilizzare [testWidgets] per test di rendering e interazione;
/// - utilizzare [test] per test di logica pura;
/// - ogni gruppo di test deve essere racchiuso in un [group] con nome descrittivo.
void main() {
  group('Smoke test - Avvio applicazione', () {
    testWidgets(
      "L'applicazione si avvia e renderizza il widget radice senza errori",
      (WidgetTester tester) async {
        await tester.pumpWidget(const MainApp());

        expect(find.byType(MaterialApp), findsOneWidget);
      },
    );
  });

  group('Smoke test - DashboardButtonWidget', () {
    testWidgets(
      'Il widget si istanzia e si renderizza senza errori con tutti i parametri obbligatori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DashboardButtonWidget(
                title: 'Test',
                description: 'Descrizione di test',
                icon: Icons.star,
                backgroundColor: Colors.blue.shade50,
                iconColor: Colors.blue,
                onTap: () {},
              ),
            ),
          ),
        );

        expect(find.byType(DashboardButtonWidget), findsOneWidget);
      },
    );
  });

  group('Smoke test - HomeScreen', () {
    testWidgets(
      'Il widget si renderizza senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: HomeScreen()),
        );

        // pump aggiuntivo per permettere al ChangeNotifierProvider di stabilizzarsi
        await tester.pump();

        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Il pulsante FAB apre il pannello emergenza senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: HomeScreen()),
        );

        await tester.pump();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsOneWidget);
      },
    );
  });

  group('Smoke test - TrustedContactScreen', () {
    testWidgets(
      'Il widget si istanzia e si renderizza senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: TrustedContactScreen()),
        );

        // Attendiamo che il caricamento asincrono dei contatti mock si completi
        await tester.pumpAndSettle();

        expect(find.byType(TrustedContactScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Il pulsante elimina apre il dialogo di conferma senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: TrustedContactScreen()),
        );

        // Attendiamo che il caricamento asincrono dei contatti mock si completi
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );
  });
}
