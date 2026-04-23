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
  });
}
