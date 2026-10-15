import 'package:gear_up_bloc/main.dart';
import 'package:gear_up_bloc/main/app_env.dart';

/// Development environment entry point.
///
/// Run this with: `flutter run -t lib/main/main_dev.dart`
///
/// This entry point:
/// - Uses development API endpoints
/// - Enables debug logging
/// - Shows debug banners/tools
Future<void> main() async => mainCommon(AppEnvironment.dev);
