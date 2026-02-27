import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

typedef OnFCMUserMessage =
    void Function(String title, String body, String type);
typedef OnFCMStaffMessage =
    void Function(String title, String body, String type);

class _Keys {
  static const fcmToken = 'fcm_token';
}

/// ─────────────────────────────────────────────────────────────────────────────
/// ✅ TOP-LEVEL BACKGROUND HANDLER (MUST be top-level)
/// ─────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // ✅ Always init Firebase in background isolate
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // If already initialized, ignore.
  }

  final FlutterLocalNotificationsPlugin local =
      FlutterLocalNotificationsPlugin();

  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    iOS: DarwinInitializationSettings(),
  );

  await local.initialize(
    settings: settings,
    onDidReceiveBackgroundNotificationResponse: _backgroundNotificationTapped,
  );

  // ✅ Re-create Android channels in background isolate
  if (!kIsWeb && Platform.isAndroid) {
    final android =
        local
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await _createAndroidChannels(android);
  }

  final data = message.data;

  final title =
      message.notification?.title ??
      data['title']?.toString() ??
      'Notification';

  final body = message.notification?.body ?? data['body']?.toString() ?? '';

  // Prefer explicit channel_id; otherwise derive from "type"
  final type = data['type']?.toString() ?? '';
  final channelId =
      (data['channel_id']?.toString().trim().isNotEmpty == true)
          ? data['channel_id'].toString()
          : _channelIdForType(type);

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
        sound: '$soundName.caf',
      ),
    ),
    payload: jsonEncode(data),
  );
}

/// ─────────────────────────────────────────────────────────────────────────────
/// ✅ ANDROID CHANNELS (must be callable from background + foreground)
/// ─────────────────────────────────────────────────────────────────────────────
Future<void> _createAndroidChannels(
  AndroidFlutterLocalNotificationsPlugin? android,
) async {
  if (android == null) return;

  const channels = <AndroidNotificationChannel>[
    // USER SIDE
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
      'ehc_new_shift',
      'New Shift',
      description: 'New shift notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('new_shift'),
    ),

    // STAFF SIDE
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
      description: 'Staff shift claim / requests notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    ),

    // DEFAULT
    AndroidNotificationChannel(
      'ehc_default_v2',
      'General',
      description: 'General notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification'),
    ),
  ];

  for (final c in channels) {
    await android.createNotificationChannel(c);
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// ✅ CHANNEL + SOUND HELPERS
/// ─────────────────────────────────────────────────────────────────────────────

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

String _channelIdForType(String type) {
  switch (type) {
    // user side types
    case 'shift-approved':
      return 'ehc_shift_approved';
    case 'shift-rejected':
      return 'ehc_shift_rejected';
    case 'new-shift':
      return 'ehc_new_shift';

    // staff side types (your API/log types)
    case 'staff-signout':
      return 'ehc_staff_signout';
    case 'staff-acpt-req':
    case 'organiz-add-reqst':
      return 'ehc_staff_accept';

    default:
      return 'ehc_default_v2';
  }
}

@pragma('vm:entry-point')
void _backgroundNotificationTapped(NotificationResponse response) {
  debugPrint('🔔 Background notification tapped: ${response.payload}');
  // TODO: navigate via global navigator key if needed
}

/// ─────────────────────────────────────────────────────────────────────────────
/// ✅ FCMService (Foreground + Tap handling + BLoC routing)
/// ─────────────────────────────────────────────────────────────────────────────
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  bool _inited = false;

  // Hook these from your app after blocs are created
  OnFCMUserMessage? onUserMessage;
  OnFCMStaffMessage? onStaffMessage;

  static const _staffTypes = {
    'staff-signout',
    'staff-acpt-req',
    'organiz-add-reqst',
  };

  static bool isStaffType(String? type) => _staffTypes.contains(type);

  /// Call once after Firebase.initializeApp(), before runApp UI.
  Future<void> init() async {
    if (_inited) return;

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      criticalAlert: true,
    );

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
        // TODO: navigate via navigator key
      },
      onDidReceiveBackgroundNotificationResponse: _backgroundNotificationTapped,
    );

    if (!kIsWeb && Platform.isAndroid) {
      final android =
          _local
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      await _createAndroidChannels(android);
    }

    // ✅ Foreground: show status-bar notification + update correct BLoC
    FirebaseMessaging.onMessage.listen((message) async {
      debugPrint('📨 Foreground FCM: ${message.messageId}');
      await _showFromRemoteMessage(message);
      _dispatchToBloc(message);
    });

    // ✅ App opened via notification tap (background)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('📲 Opened via notification: ${message.messageId}');
      _dispatchToBloc(message);
    });

    // ✅ App launched via notification tap (terminated)
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('🚀 Launched via notification: ${initial.messageId}');
      _dispatchToBloc(initial);
    }

    _messaging.onTokenRefresh.listen((token) async {
      await _saveTokenLocal(token);
      debugPrint('🔁 FCM token refreshed: $token');
    });

    _inited = true;
    debugPrint('✅ FCMService initialized');
  }

  void _dispatchToBloc(RemoteMessage message) {
    final data = message.data;
    final type = data['type']?.toString() ?? '';
    final title =
        message.notification?.title ??
        data['title']?.toString() ??
        'Notification';
    final body = message.notification?.body ?? data['body']?.toString() ?? '';

    if (isStaffType(type)) {
      onStaffMessage?.call(title, body, type);
    } else {
      onUserMessage?.call(title, body, type);
    }
  }

  Future<void> _showFromRemoteMessage(RemoteMessage message) async {
    final data = message.data;

    final title =
        message.notification?.title ??
        data['title']?.toString() ??
        'Notification';
    final body = message.notification?.body ?? data['body']?.toString() ?? '';

    final type = data['type']?.toString() ?? '';

    final channelId =
        (data['channel_id']?.toString().trim().isNotEmpty == true)
            ? data['channel_id'].toString()
            : _channelIdForType(type);

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
          sound: '$soundName.caf',
        ),
      ),
      payload: jsonEncode(data),
    );
  }

  // ── Token helpers ─────────────────────────────────────────────────────────

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
}
