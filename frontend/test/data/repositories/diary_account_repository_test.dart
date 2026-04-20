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
      () {
        mockService.returnValue = 0;
        expect(repository.clarifyAccessResult(""), DiaryAccessResult.error);
        mockService.returnValue = 1;
        expect(repository.clarifyAccessResult(""), DiaryAccessResult.realDiary);
        mockService.returnValue = 2;
        expect(repository.clarifyAccessResult(""), DiaryAccessResult.fakeDiary);
        mockService.returnValue = 3;
        expect(
          repository.clarifyAccessResult(""),
          DiaryAccessResult.tooManyAttempts,
        );
      },
    );
  });
}
