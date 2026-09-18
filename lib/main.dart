import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'shared/bindings/initial_binding.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // .env is optional in dev — EnvConfig falls back to --dart-define values
  // or sane defaults if the file is missing, so this must not throw.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // No .env file present; continuing with EnvConfig defaults.
  }

  // Resolve async singletons (SharedPreferences, etc.) before first frame.
  await InitialBinding.initAsync();

  runApp(const CampusConnectApp());
}
