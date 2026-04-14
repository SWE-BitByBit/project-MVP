class DiaryAccountService {
  int validateDiaryPassword(String pwd) {
    ///PLACEHOLDER
    //TODO: implementare chiamata reale
    if (pwd == "testpassword") {
      return 1;
    } else if (pwd == "fakepassword") {
      return 2;
    }
    return 0;
  }
}
