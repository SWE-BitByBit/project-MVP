import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/diary_account_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/repositories/note_repository.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/diary_account_service.dart';
import 'package:mvp_app_protegge_e_trasforma/data/services/note_service.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_viewmodel.dart';
import 'package:provider/provider.dart';

/// Istanzia le dipendenze e poi fa dependency injection tramite [ChangeNotifierProvider]
/// Logica di stato e l'effettiva costruzione della UI delegate a viewmodel e widget
class DiaryPasswordSetting extends StatelessWidget {
  const DiaryPasswordSetting({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final service = NoteService();
        final repository = NoteRepository(service);
        final accService = DiaryAccountService();
        final accRepository = DiaryAccountRepository(accService);
        final viewmodel = DiaryViewmodel(repository, accRepository);
        return viewmodel;
      },
      child: const DiaryPasswordSettingWidget(),
    );
  }
}

class DiaryPasswordSettingWidget extends StatelessWidget {
  const DiaryPasswordSettingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController realPassword = TextEditingController();
    final TextEditingController fakePassword1 = TextEditingController();
    final TextEditingController fakePassword2 = TextEditingController();
    BorderSide field1Border = BorderSide(color: Colors.black87);
    BorderSide field2Border = BorderSide(color: Colors.black87);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 75,
        title: const Text('Password diario fittizio'),
        centerTitle: true,
        backgroundColor: Colors.teal.shade200,
      ),
      body: Center(
        child: Consumer<DiaryViewmodel>(
          builder: (context, viewModel, child) {
            if (viewModel.passwordMatch != null) {
              if (viewModel.passwordMatch == false) {
                field2Border = BorderSide(color: Colors.red, width: 1.5);
              } else {
                field2Border = BorderSide(color: Colors.green, width: 1.5);
              }
            }
            if (viewModel.passwordError.isNotEmpty) {
              field1Border = BorderSide(color: Colors.red, width: 1.5);
            } else {
              field1Border = BorderSide(color: Colors.black87);
            }
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (viewModel.fakePwdSet)
                    Container(
                      width: double.infinity,
                      color: const Color.fromARGB(255, 236, 255, 235),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              "Password impostata con successo.\n",
                              style: const TextStyle(
                                color: Color.fromARGB(255, 5, 116, 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Expanded(
                    ///!!!!
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          obscureText: true,
                          controller: realPassword,
                          decoration: InputDecoration(
                            labelText: "Password diario reale",
                            enabledBorder: OutlineInputBorder(
                              borderSide: field1Border,
                            ),
                          ),
                        ),
                        SizedBox(height: 28),
                        TextFormField(
                          obscureText: true,
                          controller: fakePassword1,
                          decoration: InputDecoration(
                            labelText: "Nuova password diario fittizio",
                            enabledBorder: OutlineInputBorder(
                              borderSide: field1Border,
                            ),
                          ),
                          onChanged: (value) {
                            viewModel.validateDiaryPassword(fakePassword1.text);
                            viewModel.checkPwdMatch(value, fakePassword2.text);
                          },
                        ),
                        SizedBox(height: 28),
                        TextFormField(
                          obscureText: true,
                          controller: fakePassword2,
                          decoration: InputDecoration(
                            labelText: "Reinserire password diario fittizio",
                            enabledBorder: OutlineInputBorder(
                              borderSide: field2Border,
                            ),
                          ),
                          onChanged: (value) => viewModel.checkPwdMatch(
                            value,
                            fakePassword1.text,
                          ),
                        ),
                        (viewModel.passwordMatch != null &&
                                viewModel.passwordMatch == false)
                            ? Text(
                                "Le password non combaciano.\n",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              )
                            : SizedBox(height: 20),
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 49,
                          child: (viewModel.isLoading())
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: () {
                                    viewModel.resetFakePasswordState();
                                    viewModel.validateDiaryPassword(
                                      fakePassword1.text,
                                    );
                                    viewModel.submitDiaryPassword(
                                      realPassword.text,
                                      fakePassword1.text,
                                    );
                                  },
                                  child: Text(
                                    "Imposta password",
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                        ),
                        (viewModel.passwordError.isNotEmpty)
                            ? Text(
                                viewModel.passwordError,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              )
                            : SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
