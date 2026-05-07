import 'package:flutter/material.dart';
import 'package:mvp_app_protegge_e_trasforma/ui/diary/view_model/diary_access_view_model.dart';
import 'package:provider/provider.dart';

class PasswordFormWidget extends StatefulWidget {
  final VoidCallback onDismiss;
  const PasswordFormWidget({super.key, required this.onDismiss});

  @override
  State<PasswordFormWidget> createState() => _PasswordFormWidget();
}

class _PasswordFormWidget extends State<PasswordFormWidget> {
  final TextEditingController _passwordController = TextEditingController();
  late DiaryAccessViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = context.read<DiaryAccessViewModel>();

    _vm.asyncError.addListener(_onErrorChanged);
  }

  /// Funzione che scatta ogni volta che asyncError cambia valore
  void _onErrorChanged() {
    final error = _vm.asyncError.value;

    if (!mounted) return;

    // Se c'è un errore, mostra lo SnackBar
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error, style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );

      // Resettiamo subito la variabile per evitare che lo SnackBar ricompaia se il widget viene ricostruito
      _vm.asyncError.value = null;
    }
  }

  @override
  void dispose() {
    _vm.asyncError.removeListener(_onErrorChanged);
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(
        context,
      ).unfocus(), // Chiude la tastiera cliccando fuori
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 64, color: Colors.teal),
                const SizedBox(height: 16),
                const Text(
                  'Accedi al diario',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 26),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password diario',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onSubmitted: (value) {
                    FocusScope.of(context).unfocus();
                    _vm.login.run(value);
                  },
                ),
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  height: 49,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _vm.login.run(_passwordController.text);
                    },
                    child: const Text('Accedi', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
