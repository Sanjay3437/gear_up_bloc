import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_language.dart';
import 'core/database/hive_storage_service.dart';
import 'core/dependency_injection/injector.dart';
import 'main/app.dart';
import 'main/app_env.dart';

/// Production entry point.
///
/// This is the default entry point when running `flutter run` without
/// specifying a target file. It initializes the app in Production mode.
void main() => mainCommon(AppEnvironment.prod);

/// Common initialization function shared across all environments.
///
/// This function:
/// 1. Ensures Flutter bindings are initialized
/// 2. Locks the app to portrait orientation
/// 3. Initializes the environment configuration
/// 4. Loads translation files for localization
/// 5. Sets up dependency injection
/// 6. Initializes local storage (Hive)
/// 7. Runs the app
///
/// [environment] - The target environment (dev, stage, prod)

Future<void> mainCommon(AppEnvironment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait mode
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize environment-specific configuration
  EnvInfo.initialize(environment);

  // Load translations for the app
  Map<String, Map<String, String>> translations = await loadTranslations();

  // Initialize dependency injection
  await init();

  // Initialize local database
  await injector<HiveService>().init();

  // Load saved language locale
  final initialLocale = await AppLanguage.getInitialLocale();

  // Run the app
  runApp(MyApp(
    languageConfig: translations,
    initialLocale: initialLocale,
  ));
}

// Future<void> mainCommon(AppEnvironment environment) async {
//   WidgetsFlutterBinding.ensureInitialized();
//   debugPrint("🟢 1. Flutter binding initialized");
//
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//
//   EnvInfo.initialize(environment);
//   debugPrint("🟢 2. EnvInfo initialized: ${EnvInfo.baseUrl}");
//
//   Map<String, Map<String, String>> translations = {};
//   try {
//     translations = await loadTranslations();
//     debugPrint("🟢 3. Translations loaded");
//   } catch (e) {
//     debugPrint("🔴 Translations failed: $e");
//   }
//
//   try {
//     await init();
//     debugPrint("🟢 4. Dependency Injection initialized");
//   } catch (e) {
//     debugPrint("🔴 DI init failed: $e");
//   }
//
//   try {
//     debugPrint("🟢 5. Initializing HiveService...");
//     await injector<HiveService>().init().timeout(
//       const Duration(seconds: 4),
//       onTimeout: () {
//         debugPrint("⚠️ HiveService init timed out!");
//       },
//     );
//     debugPrint("🟢 5b. HiveService initialized");
//   } catch (e) {
//     debugPrint("🔴 HiveService init failed: $e");
//   }
//
//   Locale initialLocale = const Locale('en');
//   try {
//     initialLocale = await AppLanguage.getInitialLocale().timeout(
//       const Duration(seconds: 2),
//       onTimeout: () => const Locale('en'),
//     );
//     debugPrint("🟢 6. Initial locale resolved: $initialLocale");
//   } catch (e) {
//     debugPrint("🔴 Locale failed: $e");
//   }
//
//   debugPrint("🟢 7. Calling runApp()...");
//   runApp(MyApp(
//     languageConfig: translations,
//     initialLocale: initialLocale,
//   ));
// }