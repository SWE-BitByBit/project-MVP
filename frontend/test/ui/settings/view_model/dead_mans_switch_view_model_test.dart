import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/settings/view_model/dead_mans_switch_view_model.dart';

void main() {
  group('DeadMansSwitchViewModel Unit Test', () {
    late DeadMansSwitchViewModel viewModel;

    setUp(() {
      viewModel = DeadMansSwitchViewModel();
    });

    test('Valori iniziali di default corretti', () {
      expect(viewModel.isActive, isFalse);
      expect(viewModel.firstTimerValue, 1);
      expect(viewModel.firstTimerUnit, 'Giorni');
      expect(viewModel.secondTimerValue, 12);
      expect(viewModel.secondTimerUnit, 'Ore');
    });

    test('I metodi set aggiornano i valori e le unità correttamente', () {
      viewModel.setFirstTimerValue(3);
      expect(viewModel.firstTimerValue, 3);

      viewModel.setFirstTimerUnit('Settimane');
      expect(viewModel.firstTimerUnit, 'Settimane');

      viewModel.setSecondTimerValue(48);
      expect(viewModel.secondTimerValue, 48);

      viewModel.setSecondTimerUnit('Giorni');
      expect(viewModel.secondTimerUnit, 'Giorni');
    });
  });
}
