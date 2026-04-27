import 'package:flutter_test/flutter_test.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_access_result.dart';

import '../../../testing/mocks/mock_diary_account_service.dart';

void main() {
  group("DiaryAccountRepository", () {
    late MockDiaryAccountService mockService;
    late DiaryAccountRepository repository;
    setUp(() {
      mockService = MockDiaryAccountService();
      repository = DiaryAccountRepository(mockService);
    });

    test(
      "clarifyAccessResult mappa correttamente i risultati di validateDiaryPassword in valori di DiaryAccessResult",
      () async {
        mockService.returnValue = 0;
        final res0 = await repository.clarifyAccessResult("");
        expect(res0, DiaryAccessResult.error);
        mockService.returnValue = 1;
        final res1 = await repository.clarifyAccessResult("");
        expect(res1, DiaryAccessResult.realDiary);
        mockService.returnValue = 2;
        final res2 = await repository.clarifyAccessResult("");
        expect(res2, DiaryAccessResult.fakeDiary);
        mockService.returnValue = 3;
        final res3 = await repository.clarifyAccessResult("");
        expect(res3, DiaryAccessResult.tooManyAttempts);
      },
    );

    test(
      "registerFakeDiaryPassword ritorna una stringa di errore se la password passata non rispetta i parametri oppure è identica ad una password esistente",
      () async {
        /// Password valida
        final s0 = await repository.registerFakeDiaryPassword("!S4mPL3pwd!");
        expect(s0, "");
        final s1 = await repository.registerFakeDiaryPassword("S4mPL3pwdaaa");
        expect(s1, "Inserire una password valida");
        mockService.duplicatePw = "!S4mPL3pwd!";
        final s2 = await repository.registerFakeDiaryPassword("!S4mPL3pwd!");
        expect(
          s2,
          "La password del diario fittizio non può essere identica alla password del diario reale",
        );
      },
    );
  });
}
