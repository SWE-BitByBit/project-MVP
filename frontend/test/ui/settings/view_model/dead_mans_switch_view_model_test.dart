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
      expect(viewModel.firstTimerMinutes, 15);
      expect(viewModel.secondTimerMinutes, 5);
      expect(viewModel.error, isNull);
    });

    test('toggleActive modifica lo stato di attivazione', () {
      viewModel.toggleActive(true);
      expect(viewModel.isActive, isTrue);

      viewModel.toggleActive(false);
      expect(viewModel.isActive, isFalse);
    });

    test('setFirstTimer aggiorna il primo timer', () {
      viewModel.setFirstTimer(30);
      expect(viewModel.firstTimerMinutes, 30);
    });

    test('setSecondTimer aggiorna il secondo timer', () {
      viewModel.setSecondTimer(10);
      expect(viewModel.secondTimerMinutes, 10);
    });
  });
}