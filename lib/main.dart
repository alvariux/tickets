import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'package:tickets/pages/camera_home_page.dart';

Future<void> main() async {
  // Run all initialization inside the same zone to avoid "Zone mismatch".
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Global Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details);
    };

    // Try to load `.env` packaged with the app. If it doesn't exist or fails
    // to load, continue and AppConfig will fall back to secure storage/defaults.
    try {
      await dotenv.load(fileName: '.env');
      debugPrint('dotenv loaded from .env: API_URL=${dotenv.env['API_URL']} API_KEY=${dotenv.env['API_KEY'] != null ? '***' : 'null'}');
    } catch (e) {
      debugPrint('dotenv: .env not found or failed to load; proceeding with defaults and secure storage');
    }

    runApp(const MyApp());
  }, (error, stack) {
    FlutterError.dumpErrorToConsole(FlutterErrorDetails(exception: error, stack: stack));
  });
}

class MyApp extends StatelessWidget {
	const MyApp({super.key});

	@override
	Widget build(BuildContext context) {
		return const MaterialApp(
			home: CameraHomePage(),
			debugShowCheckedModeBanner: false,
		);
	}
}
