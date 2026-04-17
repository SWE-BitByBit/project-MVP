import 'package:flutter/material.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../view_model/auth_view_model.dart';
import 'header_widget.dart';
import 'google_login_button_widget.dart';
import 'logged_in_banner_widget.dart';

/// Rappresenta la schermata principale per l'autenticazione dell'utente.
class LoginScreen extends StatefulWidget {
  /// Repository per la gestione dell'autenticazione.
  final AuthRepository authRepository;

  /// Inizializza la schermata con il [authRepository] fornito.
  const LoginScreen({super.key, required this.authRepository});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// View Model per la gestione dello stato della schermata di login.
  late final AuthViewModel _viewModel;

  /// Inizializza i servizi e i componenti necessari per la schermata.
  @override
  void initState() {
    super.initState();
    _viewModel = AuthViewModel(widget.authRepository);
    _viewModel.checkExistingSession();
  }

  /// Esegue la pulizia delle risorse, tra cui la chiusura del [_viewModel].
  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  /// Costruisce l'interfaccia utente complessiva delegando la logica ai widget figli.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.teal.shade200,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListenableBuilder(
              listenable: Listenable.merge([_viewModel, _viewModel.login, _viewModel.logout]),
              builder: (context, child) {
                final isUserLoggedIn = _viewModel.currentUser != null;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const HeaderWidget(),
                    const SizedBox(height: 48),

                    if (_viewModel.login.error != null) ...[
                      Text(
                        _viewModel.login.error.toString().replaceAll('Exception: ', ''),
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (isUserLoggedIn) ...[
                      LoggedInBannerWidget(
                        email: _viewModel.currentUser!.email,
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () => _viewModel.logout.execute(),
                        child: const Text(
                          'Disconnetti',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ] else ...[
                      GoogleLoginButtonWidget(
                        isLoading: _viewModel.login.running,
                        onPressedCallback: () async {
                          await _viewModel.login.execute();
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'L\'accesso è consentito solo tramite account Google ufficiale.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
