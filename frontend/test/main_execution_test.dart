import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mvp_app_protegge_e_trasforma/main.dart' as app;

void main() {
  testWidgets('Test della funzione main() per copertura inizializzazione', (WidgetTester tester) async {
    // Forziamo il caricamento di variabili d'ambiente fittizie
    dotenv.loadFromString(envString: 'COGNITO_DOMAIN=test\nCOGNITO_CLIENT_ID=test');
    
    // Chiamiamo il main dell'applicazione.
    // Questo caricherà i repository e inizierà il build di MainApp.
    await app.main();
    
    // Lasciamo che il loop di Flutter processi il build
    await tester.pump();
    
    // Verifichiamo che il widget radice sia stato montato correttamente,
    // a conferma che la funzione main() è arrivata all'istruzione runApp().
    expect(find.byType(app.MainApp), findsOneWidget);
  });
}
