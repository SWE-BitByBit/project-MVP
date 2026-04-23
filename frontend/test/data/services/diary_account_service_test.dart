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
      () async {
        final res1 = await service.validateDiaryPassword("testpassword");
        final res2 = await service.validateDiaryPassword("fakepassword");
        final res3 = await service.validateDiaryPassword("tasddsaddsad");

        expect(res1, 1);
        expect(res2, 2);
        expect(res3, 0);
      },
    );
  });
}
