import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';
import 'package:provider/provider.dart';

/// Istanzia le dipendenze tramite GetIt e fa dependency injection con [ChangeNotifierProvider]
class DiaryPasswordSetting extends StatelessWidget {
  final bool isModifyingRealPassword;

  const DiaryPasswordSetting({
    super.key,
    this.isModifyingRealPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    // Passiamo l'istanza globale già esistente al widget figlio.
    return ChangeNotifierProvider.value(
      value: context.read<DiaryAccessViewModel>(),
      child: DiaryPasswordSettingWidget(isModifyingRealPassword: isModifyingRealPassword),
    );
  }
}

class DiaryPasswordSettingWidget extends StatefulWidget {
  final bool isModifyingRealPassword;
  const DiaryPasswordSettingWidget({super.key, required this.isModifyingRealPassword});

  @override
  State<DiaryPasswordSettingWidget> createState() => _DiaryPasswordSettingWidgetState();
}

class _DiaryPasswordSettingWidgetState extends State<DiaryPasswordSettingWidget> {
  late final TextEditingController _realPassword;
  late final TextEditingController _newPassword1;
  late final TextEditingController _newPassword2;

  bool _passwordsMatch = true;

  @override
  void initState() {
    super.initState();
    _realPassword = TextEditingController();
    _newPassword1 = TextEditingController();
    _newPassword2 = TextEditingController();
  }

  @override
  void dispose() {
    _realPassword.dispose();
    _newPassword1.dispose();
    _newPassword2.dispose();
    super.dispose();
  }

  void _checkMatch() {
    setState(() {
      if (_newPassword2.text.isNotEmpty) {
        _passwordsMatch = _newPassword1.text == _newPassword2.text;
      } else {
        _passwordsMatch = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String titleText = widget.isModifyingRealPassword
        ? 'Modifica Password Reale'
        : 'Password Diario Fittizio';

    final String newPasswordLabel = widget.isModifyingRealPassword
        ? 'Nuova password reale'
        : 'Nuova password fittizia';

    // Avvolge lo Scaffold in una SafeArea
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 75,
          title: Text(titleText),
          centerTitle: true,
          backgroundColor: Colors.teal.shade200,
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.read<DiaryAccessViewModel>().resetFormState();
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Center(
          child: Consumer<DiaryAccessViewModel>(
            builder: (context, viewModel, child) {

              BorderSide field1Border = viewModel.passwordError.isNotEmpty
                  ? const BorderSide(color: Colors.red, width: 1.5)
                  : const BorderSide(color: Colors.black87);

              BorderSide field2Border = !_passwordsMatch
                  ? const BorderSide(color: Colors.red, width: 1.5)
                  : const BorderSide(color: Colors.black87);

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // --- CAMPO: PASSWORD VECCHIA ---
                          TextFormField(
                            obscureText: true,
                            controller: _realPassword,
                            decoration: const InputDecoration(
                              labelText: "Password diario reale attuale",
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          // --- CAMPO: NUOVA PASSWORD
                          TextFormField(
                            obscureText: true,
                            controller: _newPassword1,
                            decoration: InputDecoration(
                              labelText: newPasswordLabel,
                              enabledBorder: OutlineInputBorder(borderSide: field1Border),
                            ),
                            onChanged: (value) {
                              viewModel.validateInput(value);
                              _checkMatch();
                            },
                          ),
                          const SizedBox(height: 28),

                          // --- CAMPO: CONFERMA PASSWORD---
                          TextFormField(
                            obscureText: true,
                            controller: _newPassword2,
                            decoration: InputDecoration(
                              labelText: "Reinserire $newPasswordLabel",
                              enabledBorder: OutlineInputBorder(borderSide: field2Border),
                            ),
                            onChanged: (value) => _checkMatch(),
                          ),

                          (!_passwordsMatch)
                              ? const Text(
                            "Le password non combaciano.\n",
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          )
                              : const SizedBox(height: 20),

                          const SizedBox(height: 8),

                          // --- BOTTONE SALVATAGGIO ---
                          SizedBox(
                            width: double.infinity,
                            height: 49,
                            child: ElevatedButton(
                              onPressed: () async {
                                viewModel.validateInput(_newPassword1.text);

                                if (_passwordsMatch && viewModel.passwordError.isEmpty) {
                                  FocusScope.of(context).unfocus();

                                  if (widget.isModifyingRealPassword) {
                                    await viewModel.updateRealPassword(
                                      _realPassword.text,
                                      _newPassword1.text,
                                    );
                                  } else {
                                    await viewModel.submitFakePassword(
                                      _realPassword.text,
                                      _newPassword1.text,
                                    );
                                  }

                                  if (viewModel.setupSuccess && context.mounted) {
                                    Navigator.of(context).pop();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Password impostata con successo."),
                                        backgroundColor: Colors.teal,
                                        behavior: SnackBarBehavior.floating,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );

                                    viewModel.resetFormState();
                                  }
                                }
                              },
                              child: const Text(
                                "Imposta password",
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ),

                          (viewModel.passwordError.isNotEmpty)
                              ? Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Text(
                              viewModel.passwordError,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          )
                              : const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}