import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../utils/locator.dart';
import '../view_model/auth_view_model.dart';
import 'header_widget.dart';
import 'google_login_button_widget.dart';
import 'logged_in_banner_widget.dart';
import '../../core/widgets/error_banner_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>(
      create: (_) => getIt<AuthViewModel>()..checkExistingSession(),
      child: Consumer<AuthViewModel>(
        builder: (context, viewModel, child) {
          final isUserLoggedIn = viewModel.currentUser != null;
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Login'),
              backgroundColor: colorScheme.primaryContainer,
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const HeaderWidget(),
                      const SizedBox(height: 48),


                      ValueListenableBuilder(
                        valueListenable: viewModel.login.errors,
                        builder: (context, commandError, _) {
                          if (commandError != null) {
                            return ErrorBannerWidget(
                              error: commandError.error.toString().replaceFirst('Exception: ', ''),
                              onClose: () => viewModel.login.clearErrors(),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      if (isUserLoggedIn) ...[
                        LoggedInBannerWidget(
                          email: viewModel.currentUser!.email,
                        ),
                        const SizedBox(height: 20),
                        TextButton(

                          onPressed: viewModel.logout.run,
                          child: Text(
                            'Disconnetti',
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      ] else ...[


                        ValueListenableBuilder<bool>(
                          valueListenable: viewModel.login.isRunning,
                          builder: (context, isRunning, _) {
                            return GoogleLoginButtonWidget(
                              isLoading: isRunning,
                              // AGGIORNAMENTO 4: Da execute a run
                              onPressedCallback: isRunning ? () {} : viewModel.login.run,
                            );
                          },
                        ),

                        const SizedBox(height: 16),
                        Text(
                          'L\'accesso è consentito solo tramite account Google ufficiale.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}