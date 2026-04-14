class DiaryAccountService {
  int validateDiaryPassword(String pwd) {
    ///PLACEHOLDER
    if (pwd == "testpassword") {
      return 1;
    } else if (pwd == "fakepassword") {
      return 2;
    }
    return 0;
  }
}
