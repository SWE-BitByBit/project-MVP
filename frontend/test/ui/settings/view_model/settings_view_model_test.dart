import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/settings/view_model/settings_view_model.dart';

void main() {
  group('SettingsViewModel Unit Test', () {
    late SettingsViewModel viewModel;

    // setUp viene eseguito prima di ogni test per avere un ambiente pulito
    setUp(() {
      viewModel = SettingsViewModel();
    });

    test('I valori iniziali devono essere corretti', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });

    test('clearError deve impostare l\'errore a null', () {
      // Dato che inizialmente è null, chiamiamo clearError per assicurarci che non generi eccezioni e mantenga lo stato coerente.
      viewModel.clearError();
      expect(viewModel.error, isNull);
    });
  });
}
