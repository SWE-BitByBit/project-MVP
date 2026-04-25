import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Modifica col tuo path reale
import 'package:mvp_app_protegge_e_trasforma/utils/app_config.dart';

void main() {
  group('AppConfig Test', () {

    setUp(() {

      dotenv.loadFromString(envString: 'DUMMY_VAR=true');
    });

    test('restituisce il fallback se API_BASE_URL non è definito', () {
      // Act & Assert
      expect(AppConfig.apiBaseUrl, 'http://127.0.0.1:3000');
    });

    test('restituisce il valore del file .env se definito', () async {
      // Arrange: Simuliamo un file .env finto in memoria
      dotenv.loadFromString(envString: '''API_BASE_URL=http://192.168.1.50:8000''');

      // Act & Assert
      expect(AppConfig.apiBaseUrl, 'http://192.168.1.50:8000');
    });
  });
}