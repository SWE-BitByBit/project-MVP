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

  ///PLACEHOLDER
  ///TODO: implementare logica registrazione password reale.
  ///Dovrebbe usare validateDiaryPassword per verificare che non sia uguale alla pwd del diario criptato o alla password esistente
  Future<int> registerFakeDiaryPassword(String pwd) async {
    await Future.delayed(Duration(milliseconds: 200));
    int check = await validateDiaryPassword(pwd);
    if (check == 0) {}
    return check;
  }
}
