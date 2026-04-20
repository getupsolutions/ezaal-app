import 'dart:async';
import 'dart:convert';
import 'dart:io';

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
    'ehc_staff_signin_v2',
    'Staff Signin',
    description: 'Staff signin notifications',
    importance: Importance.max,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('notification'),
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
    case 'staff-signin':
      return 'ehc_staff_signin_v2';
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
    case 'ehc_staff_signin_v2':
      return 'Staff Signin';
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
    case 'staff-signin':
      return 'Staff Signin';
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
    'staff-signin',
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
      int.tryParse(data['requestID']?.toString() ?? '') ??
      (message.messageId?.hashCode ?? '$type|$title|$body'.hashCode);

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

  // IMPORTANT:
  // Backend already sends `notification` payload.
  // So Android/iOS system will show it automatically in background/killed.
  // Do NOT call showFcmNotification() here, otherwise duplicate popup happens.
}

@pragma('vm:entry-point')
void _onBgNotifTap(NotificationResponse response) {
  debugPrint('🔔 BG notification tapped: ${response.payload}');
}

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  static const _kFcmTokenKey = 'fcm_token';
  static const _kLastSyncedFcmTokenKey = 'last_synced_fcm_token';
  static const _kAccessTokenKey = 'auth_access_token';
  static const _kAuthTypeKey = 'auth_type';
  static const _kHandledMessagesKey = 'handled_fcm_messages';

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
    'staff-signin',
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

        if (await _isDuplicateMessage(msg)) {
          debugPrint('ℹ️ Duplicate foreground message ignored');
          return;
        }

        await _rememberMessage(msg);
        await showFcmNotification(plugin: _local, message: msg);
        _dispatchToCallbacks(msg);
      });

      await _onMessageOpenedAppSub?.cancel();
      _onMessageOpenedAppSub = FirebaseMessaging.onMessageOpenedApp.listen((
        msg,
      ) async {
        debugPrint('📲 Opened via notification: ${msg.messageId}');

        if (await _isDuplicateOpen(msg)) {
          debugPrint('ℹ️ Duplicate opened-app event ignored');
          return;
        }

        _dispatchToCallbacks(msg);
      });

      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        debugPrint('🚀 Launched via notification: ${initial.messageId}');

        if (!await _isDuplicateOpen(initial)) {
          await Future.delayed(const Duration(milliseconds: 300));
          _dispatchToCallbacks(initial);
        }
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
    } catch (e) {
      debugPrint('❌ FCM init error: $e');
    } finally {
      _isInitializing = false;
    }
  }

  Future<String> _messageKey(RemoteMessage message) async {
    return message.messageId ??
        message.data['requestID']?.toString() ??
        message.data['id']?.toString() ??
        '${_resolveType(message)}|${_resolveTitle(message)}|${_resolveBody(message)}';
  }

  Future<List<String>> _getHandledMessages() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kHandledMessagesKey) ?? [];
  }

  Future<void> _setHandledMessages(List<String> values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kHandledMessagesKey, values);
  }

  Future<bool> _isDuplicateMessage(RemoteMessage message) async {
    final key = await _messageKey(message);
    final handled = await _getHandledMessages();
    return handled.contains('msg:$key');
  }

  Future<void> _rememberMessage(RemoteMessage message) async {
    final key = await _messageKey(message);
    final handled = await _getHandledMessages();
    handled.add('msg:$key');

    final trimmed =
        handled.length > 100 ? handled.sublist(handled.length - 100) : handled;

    await _setHandledMessages(trimmed);
  }

  Future<bool> _isDuplicateOpen(RemoteMessage message) async {
    final key = await _messageKey(message);
    final handled = await _getHandledMessages();

    if (handled.contains('open:$key')) {
      return true;
    }

    handled.add('open:$key');
    final trimmed =
        handled.length > 100 ? handled.sublist(handled.length - 100) : handled;

    await _setHandledMessages(trimmed);
    return false;
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
    await prefs.setString(_kFcmTokenKey, token);
  }

  Future<String?> getLocalToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kFcmTokenKey);
  }

  Future<void> clearLastSyncedToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastSyncedFcmTokenKey);
  }

  Future<void> setLoginContext({
    required String accessToken,
    required String authType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAccessTokenKey, accessToken);
    await prefs.setString(_kAuthTypeKey, authType);
    debugPrint('✅ Login context saved => $authType');
  }

  Future<void> clearLoginContext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAccessTokenKey);
    await prefs.remove(_kAuthTypeKey);
    debugPrint('✅ Login context cleared');
  }

  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessTokenKey);
  }

  Future<String?> _getAuthType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAuthTypeKey);
  }

  Future<void> syncTokenToServer({
    required String accessToken,
    required String baseUrl,
    required String authType,
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
      final lastSyncedToken = prefs.getString(_kLastSyncedFcmTokenKey);

      if (!force && lastSyncedToken == token) {
        debugPrint('ℹ️ FCM token already synced, skipping duplicate upload');
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/save-fcm-token'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': token,
          'auth_type': authType,
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
        await prefs.setString(_kLastSyncedFcmTokenKey, token);
        debugPrint('✅ save-fcm-token success');
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
      final accessToken = await _getAccessToken();
      final authType = await _getAuthType();

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('ℹ️ No access token found, skipping FCM sync');
        return;
      }

      if (authType == null || authType.isEmpty) {
        debugPrint('ℹ️ No auth type found, skipping FCM sync');
        return;
      }

      await syncTokenToServer(
        accessToken: accessToken,
        baseUrl: FCMConfig.baseUrl,
        authType: authType,
        force: force,
      );
    } catch (e) {
      debugPrint('❌ Error in syncTokenToServerIfLoggedIn: $e');
    }
  }

  Future<void> deleteTokenFromServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_kFcmTokenKey);
      final accessToken = prefs.getString(_kAccessTokenKey);

      if (token == null || token.isEmpty) {
        debugPrint('ℹ️ No local FCM token found for delete');
        return;
      }

      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('ℹ️ No access token found for delete-fcm-token');
        return;
      }

      final response = await http.post(
        Uri.parse('${FCMConfig.baseUrl}/delete-fcm-token'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $accessToken',
          HttpHeaders.contentTypeHeader: 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'fcm_token': token}),
      );

      debugPrint('📡 delete-fcm-token status: ${response.statusCode}');
      debugPrint('📡 delete-fcm-token body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        await prefs.remove(_kLastSyncedFcmTokenKey);
        debugPrint('✅ FCM token deleted from server');
      } else {
        debugPrint('❌ delete-fcm-token failed');
      }
    } catch (e) {
      debugPrint('❌ Error deleting FCM token: $e');
    }
  }

  Future<void> logoutCleanup() async {
    await deleteTokenFromServer();
    await clearLoginContext();
  }

  Future<void> dispose() async {
    await _onMessageSub?.cancel();
    await _onMessageOpenedAppSub?.cancel();
    await _onTokenRefreshSub?.cancel();
  }
}
