import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Modifica coi tuoi path reali
import 'package:mvp_app_protegge_e_trasforma/utils/locator.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/safeplace/view_model/safe_place_view_model.dart';

void main() {
  group('Locator Setup Test', () {
    setUp(() {
      // Svuotiamo lo scatolone prima di testarlo
      GetIt.instance.reset();

      // Poiché il locator legge AppConfig all'avvio, dobbiamo fornirgli un env finto
      dotenv.loadFromString(envString: '''API_BASE_URL=http://test.com''');
    });

    test('Dovrebbe registrare tutte le dipendenze senza errori', () {
      // 1. Act: Eseguiamo il setup reale della nostra app
      setupLocator();

      // 2. Assert: Verifichiamo che il ViewModel (e tutte le dipendenze
      // a cascata come Repository e Service) vengano istanziati senza errori.
      expect(() => getIt<SafePlaceViewModel>(), returnsNormally);

      // Verifica opzionale che sia effettivamente registrato
      expect(getIt.isRegistered<SafePlaceViewModel>(), isTrue);
    });
  });
}