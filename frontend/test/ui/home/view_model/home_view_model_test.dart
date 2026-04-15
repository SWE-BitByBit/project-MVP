import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/home/view_model/home_view_model.dart';

void main() {
  late HomeViewModel viewModel;

  setUp(() {
    viewModel = HomeViewModel();
  });

  group('HomeViewModel - Stato Iniziale', () {
    test('Lo stato iniziale deve essere pulito e senza errori', () {
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.error, isNull);
    });
  });

  group('HomeViewModel - Gestione Errori', () {
    test('clearError azzera il messaggio di errore e notifica i listener', () {
      // Arrange: impostiamo un errore manualmente accedendo al campo privato
      // tramite l'invocazione di clearError partendo da uno stato con errore.
      // Dato che _error è privato, verifichiamo il comportamento atteso
      // tramite il ChangeNotifier.
      int notifyCount = 0;
      viewModel.addListener(() => notifyCount++);

      // Act: chiamiamo clearError (che setta _error = null e notifica)
      viewModel.clearError();

      // Assert: il listener è stato chiamato e l'errore è ancora null
      expect(notifyCount, 1);
      expect(viewModel.error, isNull);
    });

    test('isLoading è sempre false (non ci sono operazioni asincrone attive)', () {
      // Il ViewModel Home è attualmente predisposto per future espansioni.
      // Verifichiamo che il getter sia stabile.
      expect(viewModel.isLoading, isFalse);
      viewModel.clearError();
      expect(viewModel.isLoading, isFalse);
    });
  });
}
