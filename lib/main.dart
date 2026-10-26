import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app/seen_app.dart';
import 'core/services/session_service.dart';
import 'firebase_options.dart';

bool firebaseReady = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firebaseReady = true;
  } catch (error) {
    firebaseReady = false;

    debugPrint('Firebase initialization failed: $error');
  }

  await SessionService.instance.initialize(
    firebaseAvailable: firebaseReady,
  );

  runApp(const SeenApp());
}