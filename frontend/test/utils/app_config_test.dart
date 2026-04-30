import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mvp_app_protegge_e_trasforma/utils/app_config.dart';

void main() {
  group('AppConfig', () {
    test('dovrebbe restituire i valori dal file .env se le chiavi sono presenti', () {
      // arrange
      dotenv.loadFromString(envString: '''
API_BASE_URL=https://api.test.com
COGNITO_DOMAIN=auth.test.com
COGNITO_CLIENT_ID=test_client_id
COGNITO_CLIENT_SECRET=test_client_secret
''');

      // act & assert
      expect(AppConfig.apiBaseUrl, 'https://api.test.com');
      expect(AppConfig.cognitoDomain, 'auth.test.com');
      expect(AppConfig.clientId, 'test_client_id');
      expect(AppConfig.clientSecret, 'test_client_secret');
    });

    test('dovrebbe restituire i valori di fallback se le chiavi nel .env sono mancanti', () {
      // arrange
      dotenv.loadFromString(envString: 'NULL=null'); // File .env vuoto

      // act & assert
      expect(AppConfig.apiBaseUrl, 'http://127.0.0.1:3000');
      expect(AppConfig.cognitoDomain, '');
      expect(AppConfig.clientId, '');
      expect(AppConfig.clientSecret, '');
    });

    test('dovrebbe restituire le costanti hardcoded corrette per gli URI di callback', () {
      // act & assert
      expect(AppConfig.callbackScheme, 'com.bitbybit.appcheproteggeetrasforma');
      expect(AppConfig.redirectUri, 'com.bitbybit.appcheproteggeetrasforma://callback');
    });
  });
}
