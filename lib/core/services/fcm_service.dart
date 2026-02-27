import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class _Keys {
  static const fcmToken = 'fcm_token';
}

// ✅ CRITICAL: Must be a TOP-LEVEL function, NOT inside any class
// This is the most common reason background notifications don't show
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ✅ Re-initialize FlutterLocalNotificationsPlugin in background isolate
  final FlutterLocalNotificationsPlugin local =
      FlutterLocalNotificationsPlugin();

  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await local.initialize(settings: settings);

  // ✅ Re-create Android channels in background isolate
  if (!kIsWeb && Platform.isAndroid) {
    final android =
        local
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await _createAndroidChannelsBackground(android);
  }

  final data = message.data;

  // ✅ Prefer notification payload, fallback to data payload
  final title =
      message.notification?.title ??
      data['title']?.toString() ??
      'Notification';

  final body = message.notification?.body ?? data['body']?.toString() ?? '';

  // ✅ Read channel_id from data payload sent by your PHP backend
  final channelId = data['channel_id']?.toString() ?? 'ehc_default_v2';

  // ✅ Map channel_id to correct sound
  final soundName = _soundForChannel(channelId);

  await local.show(
    id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelNameForId(channelId),
        channelDescription: 'Shift and healthcare updates',
        importance: Importance.max, // ✅ Use max for background
        priority: Priority.max, // ✅ Use max for background
        playSound: true,
        enableVibration: true,
        // ✅ Use the correct raw resource sound matching the channel
        sound: RawResourceAndroidNotificationSound(soundName),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
    payload: jsonEncode(data),
  );
}

// ✅ Helper: must also be top-level (called from top-level background handler)
Future<void> _createAndroidChannelsBackground(
  AndroidFlutterLocalNotificationsPlugin? android,
) async {
  if (android == null) return;

  const channels = <AndroidNotificationChannel>[
    AndroidNotificationChannel(
      'ehc_default_v2',
      'General',
      description: 'General notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    ),
    AndroidNotificationChannel(
      'ehc_new_shift',
      'New Shift',
      description: 'New shift notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('new_shift'),
    ),
    AndroidNotificationChannel(
      'ehc_shift_approved',
      'Shift Approved',
      description: 'Shift approved notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('approved'),
    ),
    AndroidNotificationChannel(
      'ehc_shift_rejected',
      'Shift Rejected',
      description: 'Shift rejected notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('rejected'),
    ),
    AndroidNotificationChannel(
      'ehc_staff_signout',
      'Staff Signout',
      description: 'Staff signout notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    ),
    AndroidNotificationChannel(
      'ehc_staff_accept',
      'Staff Shift Claim',
      description: 'Staff shift claim notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    ),
  ];

  for (final c in channels) {
    await android.createNotificationChannel(c);
  }
}

// ✅ Helper: top-level sound mapping
String _soundForChannel(String channelId) {
  switch (channelId) {
    case 'ehc_shift_approved':
      return 'approved';
    case 'ehc_shift_rejected':
      return 'rejected';
    case 'ehc_new_shift':
      return 'new_shift';
    default:
      return 'notification';
  }
}

// ✅ Helper: channel display name
String _channelNameForId(String channelId) {
  switch (channelId) {
    case 'ehc_shift_approved':
      return 'Shift Approved';
    case 'ehc_shift_rejected':
      return 'Shift Rejected';
    case 'ehc_new_shift':
      return 'New Shift';
    case 'ehc_staff_signout':
      return 'Staff Signout';
    case 'ehc_staff_accept':
      return 'Staff Shift Claim';
    default:
      return 'General';
  }
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _inited = false;

  /// Call once after Firebase.initializeApp()
  Future<void> init() async {
    if (_inited) return;

    // ✅ Request permissions
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true, // ✅ Request critical alerts too
    );

    // ✅ IMPORTANT: Set foreground notification presentation options for iOS
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        requestCriticalPermission: true,
      ),
    );

    await _local.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (resp) {
        debugPrint('🔔 Notification tapped: ${resp.payload}');
        // TODO: Navigate to appropriate screen based on payload
      },
      onDidReceiveBackgroundNotificationResponse: _backgroundNotificationTapped,
    );

    // ✅ Create Android channels
    if (!kIsWeb && Platform.isAndroid) {
      final android =
          _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await _createAndroidChannelsBackground(android);
    }

    // ✅ Foreground message → show local notification
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('📨 Foreground message received: ${message.messageId}');
      await _showFromRemoteMessage(message);
    });

    // ✅ Token refresh
    _messaging.onTokenRefresh.listen((newToken) async {
      await _saveTokenLocal(newToken);
      debugPrint('🔁 FCM token refreshed: $newToken');
    });

    _inited = true;
    debugPrint('✅ FCMService initialized');
  }

  /// ✅ Get FCM token and save to SharedPrefs
  Future<String?> getAndStoreToken() async {
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return null;
    await _saveTokenLocal(token);
    debugPrint('✅ FCM token: $token');
    return token;
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_Keys.fcmToken);
  }

  Future<void> _saveTokenLocal(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_Keys.fcmToken, token);
  }

  /// ✅ Send token to PHP backend (call after login)
  Future<void> syncTokenToServer({
    required String accessToken,
    required String baseUrl,
  }) async {
    final token = await getAndStoreToken();
    if (token == null) return;

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/save-fcm-token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'platform':
              kIsWeb
                  ? 'web'
                  : (Platform.isAndroid
                      ? 'android'
                      : Platform.isIOS
                      ? 'ios'
                      : 'other'),
        }),
      );
      debugPrint('📡 save-fcm-token status=${res.statusCode} body=${res.body}');
    } catch (e) {
      debugPrint('❌ Error syncing FCM token: $e');
    }
  }

  Future<void> _showFromRemoteMessage(RemoteMessage message) async {
    final data = message.data;

    final title =
        message.notification?.title ??
        data['title']?.toString() ??
        'Notification';

    final body = message.notification?.body ?? data['body']?.toString() ?? '';

    final channelId = data['channel_id']?.toString() ?? 'ehc_default_v2';
    final soundName = _soundForChannel(channelId);

    await _local.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          _channelNameForId(channelId),
          channelDescription: 'Shift and healthcare updates',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          enableVibration: true,
          sound: RawResourceAndroidNotificationSound(soundName),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: '${soundName}.caf',
        ),
      ),
      payload: jsonEncode(data),
    );
  }
}

// ✅ Must also be top-level for background notification tap handling
@pragma('vm:entry-point')
void _backgroundNotificationTapped(NotificationResponse response) {
  debugPrint('🔔 Background notification tapped: ${response.payload}');
}
