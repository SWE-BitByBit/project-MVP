import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/network/api_exception.dart';

void main() {
  group('ApiException Tests', () {
    test('dovrebbe memorizzare correttamente statusCode e message', () {
      // Arrange & Act
      final exception = ApiException(statusCode: 404, message: 'Not Found');

      // Assert
      expect(exception.statusCode, 404);
      expect(exception.message, 'Not Found');
    });

    test('dovrebbe formattare correttamente la stringa nel metodo toString()', () {
      // Arrange
      final exception = ApiException(statusCode: 500, message: 'Internal Server Error');

      // Act
      final result = exception.toString();

      // Assert
      expect(result, 'ApiException: [500] Internal Server Error');
    });
  });
}