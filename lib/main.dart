import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/api.dart';
import 'core/offline.dart';
import 'ui/screens.dart';

bool firebaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
    
  }

  runApp(const SeenApp());
}

class SeenApp extends StatelessWidget {
  const SeenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سين | لأن الصحافة سؤال',
      debugShowCheckedModeBanner: false,

      locale: const Locale('ar'),

      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },

      theme: ThemeData(
        useMaterial3: true,

        scaffoldBackgroundColor: const Color(0xFFF5F3EE),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF153F51),
          surface: const Color(0xFFF5F3EE),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5F3EE),
          surfaceTintColor: Colors.transparent,
          centerTitle: false,
        ),

        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 32,
            color: Color(0xFF172B36),
          ),

          headlineMedium: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Color(0xFF172B36),
          ),

          titleLarge: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF172B36),
          ),

          bodyMedium: TextStyle(height: 1.7, color: Color(0xFF35444C)),
        ),
      ),

      home: SeenShell(api: SeenApi(), offline: OfflineLibrary()),
    );
  }
}
