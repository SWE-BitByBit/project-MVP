import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';

void main() {
  group("DiaryAccountService", () {
    late DiaryAccountService service;
    setUp(() {
      service = DiaryAccountService();
    });

    test(
      "validateDiaryPassword restituisce i valori corretti in base alla password passata (placeholder in attesa di backend)",
      () {
        expect(service.validateDiaryPassword("testpassword"), 1);
        expect(service.validateDiaryPassword("fakepassword"), 2);
        expect(service.validateDiaryPassword("tasddsaddsad"), 0);
      },
    );
  });
}
