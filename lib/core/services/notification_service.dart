
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'api_client.dart';
import 'session_service.dart';

class NotificationService {
  NotificationService._();

  void _handleSessionChange() {
  if (SessionService.instance.isSignedIn) {
    registerDevice();
  }
}

  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final ApiClient _api = ApiClient();

  bool _initialized = false;
  bool _localNotificationsReady = false;
  String? _registeredToken;

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'seen_notifications',
    'إشعارات سين',
    description: 'التحديثات والإشعارات المهمة من سين',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    if (_initialized) return;

    if (!SessionService.instance.firebaseAvailable) {
      debugPrint('Notifications: Firebase is unavailable.');
      return;
    }

    await _initializeLocalNotifications();
    await _requestPermission();

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpened(initialMessage);
    }

    _messaging.onTokenRefresh.listen((token) {
      _registerToken(token);
    });

    SessionService.instance.addListener(_handleSessionChange);
    _initialized = true;
    SessionService.instance.beforeSignOut = unregisterDevice;

    if (SessionService.instance.isSignedIn) {
      await registerDevice();
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(_channel);

    _localNotificationsReady = true;
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      'Notification permission: ${settings.authorizationStatus}',
    );
  }

  Future<void> registerDevice() async {
    if (!_initialized || !SessionService.instance.isSignedIn) return;

    try {
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('Notifications: FCM token is unavailable.');
        return;
      }

      await _registerToken(token);
    } catch (error) {
      debugPrint('Notifications: token registration failed: $error');
    }
  }

  Future<void> _registerToken(String token) async {
    if (!SessionService.instance.isSignedIn) return;

    try {
      await _api.post(
        '/api/notifications/token',
        authenticated: true,
        body: {
          'token': token,
          'platform': 'android',
        },
      );

      _registeredToken = token;

      debugPrint('Notifications: device registered successfully.');
    } catch (error) {
      debugPrint('Notifications: device registration failed: $error');
    }
  }

  Future<void> unregisterDevice() async {
    final token = _registeredToken?? await _messaging.getToken();

    if (token == null || token.isEmpty) return;

    try {
      await _api.delete(
        '/api/notifications/token',
        authenticated: true,
        body: {'token': token},
      );

      _registeredToken = null;

      debugPrint('Notifications: device unregistered.');
    } catch (error) {
      debugPrint('Notifications: device unregistration failed: $error');
      rethrow;
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;

    if (notification == null || !_localNotificationsReady) return;

    await _localNotifications.show(
      notification.hashCode,
      notification.title ?? 'سين',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageOpened(RemoteMessage message) {
    debugPrint(
      'Notification opened: ${message.messageId}, data: ${message.data}',
    );

    _handleNotificationData(message.data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;

    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload);

      if (data is Map<String, dynamic>) {
        _handleNotificationData(data);
      }
    } catch (error) {
      debugPrint('Notifications: invalid notification payload: $error');
    }
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    // سيتم ربط التنقل إلى المقال أو الوجهة المناسبة
    // بعد تحديد بنية بيانات الإشعار القادمة من الخادم.
    debugPrint('Notification data received: $data');
  }
}
