import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/main.dart';
import 'package:mvp_app_protegge_e_trasforma/dashboard_button.dart';
import 'package:mvp_app_protegge_e_trasforma/trusted_contacts_page.dart';
import 'package:mvp_app_protegge_e_trasforma/contact_form_page.dart';
import 'package:mvp_app_protegge_e_trasforma/home_page.dart';

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

  group('Smoke test - DashboardButton', () {
    testWidgets(
      'Il widget si istanzia e si renderizza senza errori con tutti i parametri obbligatori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DashboardButton(
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

        expect(find.byType(DashboardButton), findsOneWidget);
      },
    );
  });

  group('Smoke test - HomePage', () {
    testWidgets(
      'Il widget si renderizza senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: HomePage()),
        );

        expect(find.byType(HomePage), findsOneWidget);
      },
    );

    testWidgets(
      'Il pulsante FAB apre il pannello emergenza senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: HomePage()),
        );

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsOneWidget);
      },
    );
  });

  group('Smoke test - ContactFormPage', () {
    testWidgets(
      'Il widget si renderizza in modalità creazione senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: ContactFormPage()),
        );

        expect(find.byType(ContactFormPage), findsOneWidget);
      },
    );

    testWidgets(
      'Il widget si renderizza in modalità modifica senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: ContactFormPage(
              initialName: 'Mario Rossi',
              initialEmail: 'mario@example.com',
              initialPhone: '+39 333 0000000',
            ),
          ),
        );

        expect(find.byType(ContactFormPage), findsOneWidget);
      },
    );

    testWidgets(
      'Il pulsante salva in modalità creazione si preme senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ContactFormPage()),
                ),
                child: const Text('Apri'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Apri'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Salva nuovo contatto'));
        await tester.pumpAndSettle();

        expect(find.text('Apri'), findsOneWidget);
      },
    );

    testWidgets(
      'Il pulsante salva in modalità modifica si preme senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ContactFormPage(
                      initialName: 'Mario Rossi',
                      initialEmail: 'mario@example.com',
                      initialPhone: '+39 333 0000000',
                    ),
                  ),
                ),
                child: const Text('Apri'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Apri'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Salva le modifiche'));
        await tester.pumpAndSettle();

        expect(find.text('Apri'), findsOneWidget);
      },
    );
  });

  group('Smoke test - TrustedContactsPage', () {
    testWidgets(
      'Il widget si istanzia e si renderizza senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: TrustedContactsPage()),
        );

        expect(find.byType(TrustedContactsPage), findsOneWidget);
      },
    );

    testWidgets(
      'Il pulsante elimina apre il dialogo di conferma senza errori',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: TrustedContactsPage()),
        );

        await tester.tap(find.byIcon(Icons.delete_outline).first);
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsOneWidget);
      },
    );
  });
}
