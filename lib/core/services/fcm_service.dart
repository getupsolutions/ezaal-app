import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

typedef OnFCMUserMessage =
    void Function(String title, String body, String type);
typedef OnFCMStaffMessage =
    void Function(String title, String body, String type);

class FCMConfig {
  static const String baseUrl =
      'https://app.ezaalhealthcare.com.au/api/v1/public';
}

const List<AndroidNotificationChannel> kEhcChannels = [
  AndroidNotificationChannel(
    'ehc_shift_approved_v2',
    'Shift Approved',
    description: 'Shift approved notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('approved'),
  ),
  AndroidNotificationChannel(
    'ehc_shift_rejected_v2',
    'Shift Rejected',
    description: 'Shift rejected notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('rejected'),
  ),
  AndroidNotificationChannel(
    'ehc_new_shift_v2',
    'New Shift',
    description: 'New shift notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('new_shift'),
  ),
  AndroidNotificationChannel(
    'ehc_staff_signout_v2',
    'Staff Signout',
    description: 'Staff signout notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
  ),
  AndroidNotificationChannel(
    'ehc_staff_accept_v2',
    'Staff Shift Claim',
    description: 'Staff shift claim notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
  ),
  AndroidNotificationChannel(
    'ehc_default_v3',
    'General',
    description: 'General notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
  ),
];

String channelIdForType(String type) {
  switch (type) {
    case 'shift-approved':
      return 'ehc_shift_approved_v2';
    case 'shift-rejected':
      return 'ehc_shift_rejected_v2';
    case 'new-shift':
    case 'organiz-add-reqst':
      return 'ehc_new_shift_v2';
    case 'staff-signout':
      return 'ehc_staff_signout_v2';
    case 'staff-acpt-req':
    case 'shift-claim-pending':
      return 'ehc_staff_accept_v2';
    default:
      return 'ehc_default_v3';
  }
}

String soundForChannel(String channelId) {
  switch (channelId) {
    case 'ehc_shift_approved_v2':
      return 'approved';
    case 'ehc_shift_rejected_v2':
      return 'rejected';
    case 'ehc_new_shift_v2':
      return 'new_shift';
    default:
      return 'notification';
  }
}

String channelNameForId(String channelId) {
  switch (channelId) {
    case 'ehc_shift_approved_v2':
      return 'Shift Approved';
    case 'ehc_shift_rejected_v2':
      return 'Shift Rejected';
    case 'ehc_new_shift_v2':
      return 'New Shift';
    case 'ehc_staff_signout_v2':
      return 'Staff Signout';
    case 'ehc_staff_accept_v2':
      return 'Staff Shift Claim';
    default:
      return 'General';
  }
}

Future<void> createAndroidChannels(
  FlutterLocalNotificationsPlugin plugin,
) async {
  if (kIsWeb || !Platform.isAndroid) return;

  final android =
      plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

  if (android == null) return;

  for (final channel in kEhcChannels) {
    await android.createNotificationChannel(channel);
  }
}

String _defaultTitleForType(String type) {
  switch (type) {
    case 'shift-approved':
      return 'Shift Approved ✓';
    case 'shift-rejected':
      return 'Shift Rejected';
    case 'new-shift':
    case 'organiz-add-reqst':
      return 'New Shift Available';
    case 'shift-claim-pending':
      return 'Shift Claim Pending';
    case 'staff-signout':
      return 'Staff Signout';
    case 'staff-acpt-req':
      return 'Shift Claimed';
    default:
      return 'Notification';
  }
}

String _resolveTitle(RemoteMessage message) {
  final data = message.data;
  final type = data['type']?.toString() ?? '';

  final dataTitle = data['title']?.toString().trim() ?? '';
  if (dataTitle.isNotEmpty) return dataTitle;

  final notifTitle = message.notification?.title?.trim() ?? '';
  if (notifTitle.isNotEmpty) return notifTitle;

  return _defaultTitleForType(type);
}

String _resolveBody(RemoteMessage message) {
  final data = message.data;

  final dataBody = data['body']?.toString().trim() ?? '';
  if (dataBody.isNotEmpty) return dataBody;

  final notifBody = message.notification?.body?.trim() ?? '';
  if (notifBody.isNotEmpty) return notifBody;

  final legacyBody = data['notification']?.toString().trim() ?? '';
  if (legacyBody.isNotEmpty) return legacyBody;

  return '';
}

String _resolveType(RemoteMessage message) {
  return message.data['type']?.toString().trim() ?? '';
}

bool _isLikelyShiftStaffPush(String type) {
  return {
    'new-shift',
    'organiz-add-reqst',
    'shift-approved',
    'shift-rejected',
    'shift-claim-pending',
    'staff-acpt-req',
    'staff-signout',
  }.contains(type);
}

Future<void> showFcmNotification({
  required FlutterLocalNotificationsPlugin plugin,
  required RemoteMessage message,
}) async {
  final data = message.data;
  final type = _resolveType(message);
  final title = _resolveTitle(message);
  final body = _resolveBody(message);

  final channelId =
      (data['channel_id']?.toString().trim().isNotEmpty ?? false)
          ? data['channel_id'].toString()
          : channelIdForType(type);

  final soundName = soundForChannel(channelId);

  final notifId =
      int.tryParse(data['id']?.toString() ?? '') ??
      DateTime.now().millisecondsSinceEpoch.remainder(1000000);

  final details = NotificationDetails(
    android: AndroidNotificationDetails(
      channelId,
      channelNameForId(channelId),
      channelDescription: 'Shift and healthcare updates',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound(soundName),
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
      icon: '@mipmap/ic_launcher',
      visibility: NotificationVisibility.public,
    ),
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: '$soundName.caf',
      interruptionLevel: InterruptionLevel.active,
    ),
  );

  await plugin.show(
    id: notifId,
    title: title,
    body: body,
    notificationDetails: details,
    payload: jsonEncode({...data, 'title': title, 'body': body, 'type': type}),
  );

  debugPrint(
    '✅ Notification shown: id=$notifId title="$title" channel=$channelId type=$type',
  );
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  debugPrint('🔔 [BG] FCM received: ${message.messageId}');
  debugPrint('🔔 [BG] data: ${message.data}');
  debugPrint('🔔 [BG] title: ${message.notification?.title}');
  debugPrint('🔔 [BG] body: ${message.notification?.body}');

  final plugin = FlutterLocalNotificationsPlugin();

  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
    onDidReceiveBackgroundNotificationResponse: _onBgNotifTap,
  );

  await createAndroidChannels(plugin);
  await showFcmNotification(plugin: plugin, message: message);
}

@pragma('vm:entry-point')
void _onBgNotifTap(NotificationResponse response) {
  debugPrint('🔔 BG notification tapped: ${response.payload}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static bool _isInitializing = false;
  static bool _isInitialized = false;

  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSub;
  StreamSubscription<String>? _onTokenRefreshSub;

  bool _isSyncingToken = false;

  OnFCMUserMessage? onUserMessage;
  OnFCMStaffMessage? onStaffMessage;

  static const Set<String> _staffTypes = {
    'new-shift',
    'organiz-add-reqst',
    'shift-approved',
    'shift-rejected',
    'shift-claim-pending',
    'staff-signout',
    'staff-acpt-req',
  };

  static bool isStaffType(String? type) => _staffTypes.contains(type);

  Future<void> init() async {
    if (_isInitialized || _isInitializing) {
      debugPrint('ℹ️ FCMService already initialized or initializing');
      return;
    }

    _isInitializing = true;

    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        criticalAlert: true,
        provisional: false,
      );
      debugPrint('📋 FCM permission: ${settings.authorizationStatus}');

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _local.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
            requestCriticalPermission: true,
          ),
        ),
        onDidReceiveNotificationResponse: (response) {
          debugPrint('🔔 [FG] tapped: ${response.payload}');
          _routePayload(response.payload);
        },
        onDidReceiveBackgroundNotificationResponse: _onBgNotifTap,
      );

      await createAndroidChannels(_local);

      if (!kIsWeb && Platform.isAndroid) {
        final android =
            _local
                .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin
                >();
        await android?.requestNotificationsPermission();
      }

      await _onMessageSub?.cancel();
      _onMessageSub = FirebaseMessaging.onMessage.listen((msg) async {
        debugPrint('📨 [FG] FCM received: ${msg.messageId}');
        debugPrint('📨 [FG] data: ${msg.data}');
        debugPrint('📨 [FG] notification.title: ${msg.notification?.title}');
        debugPrint('📨 [FG] notification.body: ${msg.notification?.body}');

        await showFcmNotification(plugin: _local, message: msg);
        _dispatchToCallbacks(msg);
      });

      await _onMessageOpenedAppSub?.cancel();
      _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((
        msg,
      ) {
        debugPrint('📲 Opened via notification: ${msg.messageId}');
        _dispatchToCallbacks(msg);
      });

      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        debugPrint('🚀 Launched via notification: ${initial.messageId}');
        await Future.delayed(const Duration(milliseconds: 300));
        _dispatchToCallbacks(initial);
      }

      final token = await getAndStoreToken();
      debugPrint('🔥 FCM TOKEN => $token');

      await _onTokenRefreshSub?.cancel();
      _onTokenRefreshSub = _messaging.onTokenRefresh.listen((token) async {
        debugPrint('🔄 FCM token refreshed => $token');
        await _saveToken(token);
        await clearLastSyncedToken();
        await syncTokenToServerIfLoggedIn(force: true);
      });

      _isInitialized = true;
      debugPrint('✅ FCMService initialized');
    } finally {
      _isInitializing = false;
    }
  }

  void _dispatchToCallbacks(RemoteMessage message) {
    final type = _resolveType(message);
    final title = _resolveTitle(message);
    final body = _resolveBody(message);

    if (_isLikelyShiftStaffPush(type) || isStaffType(type)) {
      onStaffMessage?.call(title, body, type);
    } else {
      onUserMessage?.call(title, body, type);
    }
  }

  void _routePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final type = data['type']?.toString() ?? '';
      final title = data['title']?.toString() ?? '';
      final body = data['body']?.toString() ?? '';

      if (_isLikelyShiftStaffPush(type) || isStaffType(type)) {
        onStaffMessage?.call(title, body, type);
      } else {
        onUserMessage?.call(title, body, type);
      }
    } catch (e) {
      debugPrint('❌ Error parsing notification payload: $e');
    }
  }

  Future<String?> getAndStoreToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) return null;
      await _saveToken(token);
      debugPrint('✅ FCM token stored locally: $token');
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fcm_token', token);
  }

  Future<void> clearLastSyncedToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_synced_fcm_token');
  }

  Future<void> syncTokenToServer({
    required String accessToken,
    required String baseUrl,
    bool force = false,
  }) async {
    if (_isSyncingToken) {
      debugPrint('ℹ️ Token sync already in progress, skipping');
      return;
    }

    _isSyncingToken = true;

    try {
      debugPrint('🔥 ENTER syncTokenToServer');

      final token = await getAndStoreToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No FCM token to sync');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final lastSyncedToken = prefs.getString('last_synced_fcm_token');

      // Force one upload unless you are 100% sure server already has it.
      if (!force && lastSyncedToken == token) {
        debugPrint(
          'ℹ️ Token matches local sync cache, trying server sync anyway',
        );
      }

      final response = await http.post(
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
                  : Platform.isAndroid
                  ? 'android'
                  : Platform.isIOS
                  ? 'ios'
                  : 'other',
        }),
      );

      debugPrint('📡 save-fcm-token status: ${response.statusCode}');
      debugPrint('📡 save-fcm-token body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await prefs.setString('last_synced_fcm_token', token);
      } else {
        debugPrint('❌ save-fcm-token failed');
      }
    } catch (e) {
      debugPrint('❌ Error syncing FCM token: $e');
    } finally {
      _isSyncingToken = false;
    }
  }

  Future<void> syncTokenToServerIfLoggedIn({bool force = false}) async {
    try {
      final accessToken = await TokenStorage.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('ℹ️ No access token found, skipping FCM sync');
        return;
      }

      await syncTokenToServer(
        accessToken: accessToken,
        baseUrl: FCMConfig.baseUrl,
        force: force,
      );
    } catch (e) {
      debugPrint('❌ Error in syncTokenToServerIfLoggedIn: $e');
    }
  }

  Future<void> deleteTokenFromServer({
    required String accessToken,
    required String baseUrl,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('fcm_token');
      if (token == null || token.isEmpty) return;

      final response = await http.post(
        Uri.parse('$baseUrl/delete-fcm-token'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      debugPrint('📡 delete-fcm-token status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await prefs.remove('fcm_token');
        await prefs.remove('last_synced_fcm_token');
        debugPrint('✅ FCM token deleted from server and cleared locally');
      }
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }
}
