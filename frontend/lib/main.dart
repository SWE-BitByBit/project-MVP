import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'utils/locator.dart';
import 'ui/core/themes/app_theme.dart';

// Fai attenzione che il percorso corrisponda a dove hai salvato la nuova HomeScreen
import 'ui/home/widget/home_screen.dart';

import 'ui/auth/widget/login_screen.dart';
import 'ui/auth/view_model/auth_view_model.dart';
import 'ui/diary/view_model/diary_access_view_model.dart';
import 'ui/sos/view_model/sos_view_model.dart';
import 'ui/sos/widget/sos_pull_top_widget.dart';
import 'ui/settings/widget/settings_screen.dart';
import 'ui/trusted_contacts/widget/trusted_contact_screen.dart';
import 'ui/material/widget/material_screen.dart';
import 'ui/safeplace/widget/safe_place_map_screen.dart';
import 'ui/core/widgets/auth_placeholder_screen.dart';

bool isIntegrationTest = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    developer.log("Errore critico: Impossibile caricare .env", error: e);
  }

  setupLocator();

  Command.globalExceptionHandler = (error, stackTrace) {
    developer.log(
      '⚠️ [Command Error] Intercettato globalmente',
      name: 'App.Command',
      error: error,
      stackTrace: stackTrace,
    );
  };

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => getIt<AuthViewModel>()..checkExistingSession()),
          ChangeNotifierProvider(create: (_) => getIt<SosViewModel>()),
          ChangeNotifierProvider(create: (_) => getIt<DiaryAccessViewModel>()),
        ],
        child: MaterialApp(
            title: 'Protegge e Trasforma',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            home: const HomeScreen(),
            routes: {
          '/login': (context) => const LoginScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/materials': (context) => const MaterialScreen(),
          '/safeplace': (context) => const SafePlaceMapScreen(),
          '/contacts': (context) {
            final authVm = context.watch<AuthViewModel>();
            final isLoggedIn = authVm.currentUser != null;

            return isLoggedIn
                ? const TrustedContactScreen()
                : AuthPlaceholderScreen(
              appBar: AppBar(
                title: const Text('Contatti fidati'),
                centerTitle: true,
              ),
              title: 'Contatti non disponibili',
              message: 'Effettua l\'accesso per visualizzare la lista dei contatti',
              icon: Icons.group,
            );
          },
        },
          builder: (context, child) {
            return Stack(
              children: [
                 ?child,
                const Positioned(top: 100, right: 0, child: SosPullTopWidget(),),
              ],
            );
          },
      )
    );
  }
}

