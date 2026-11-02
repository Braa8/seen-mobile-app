import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'core/services/notification_service.dart';
import 'app/seen_app.dart';
import 'core/services/session_service.dart';
import 'firebase_options.dart';

bool firebaseReady = false;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('Background message received: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    firebaseReady = true;

    FirebaseMessaging.onBackgroundMessage(
      firebaseMessagingBackgroundHandler,
    );
  } catch (error) {
    firebaseReady = false;

    debugPrint('Firebase initialization failed: $error');
  }

  await SessionService.instance.initialize(
    firebaseAvailable: firebaseReady,
  );

  if (firebaseReady) {
  await NotificationService.instance.initialize();
}

  runApp(const SeenApp());
}