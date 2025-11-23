import 'package:flutter/material.dart';
import 'package:tickets/pages/camera_home_page.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();

	// Global Flutter error handler
	FlutterError.onError = (FlutterErrorDetails details) {
		FlutterError.dumpErrorToConsole(details);
	};
	
	runApp(const MyApp());
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
