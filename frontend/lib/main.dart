import 'package:flutter/material.dart';
import 'package:command_it/command_it.dart';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'utils/locator.dart';
import 'ui/core/themes/app_theme.dart';
import 'ui/home/widget/home_screen.dart';
import 'data/repositories/auth_repository.dart';

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
    return MaterialApp(
      title: 'Protegge e Trasforma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: HomeScreen(authRepository: getIt<AuthRepository>()),
    );
  }
}