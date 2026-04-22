/// Servizio responsabile della comunicazione HTTP/REST con il backend
/// per l'accesso al diario.
class DiaryAccountService {
  Future<int> validateDiaryPassword(String pwd) async {
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
