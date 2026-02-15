import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _initialized = false;

  Future<void> _requestPermission() async {
    if (kIsWeb) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    if (Platform.isAndroid) {
      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    await _requestPermission();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      onDidReceiveNotificationResponse: _onNotificationTapped,
      settings: initSettings,
    );

    await _createNotificationChannels();

    _initialized = true;
  }

  Future<void> _createNotificationChannels() async {
    if (kIsWeb || !(Platform.isAndroid)) return;

    final android =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (android == null) return;

    // One channel per sound/type (Android limitation)
    final channels = <AndroidNotificationChannel>[
      // USER SIDE
      AndroidNotificationChannel(
        'ehc_shift_approved',
        'Shift Approved',
        description: 'Shift approved notifications',
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('approved'),
      ),
      AndroidNotificationChannel(
        'ehc_shift_rejected',
        'Shift Rejected',
        description: 'Shift rejected notifications',
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('rejected'),
      ),
      AndroidNotificationChannel(
        'ehc_new_shift',
        'New Shift',
        description: 'New shift notifications',
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('new_shift'),
      ),

      // ADMIN/STAFF SIDE (from your logs)
      AndroidNotificationChannel(
        'ehc_staff_signout',
        'Staff Signout',
        description: 'Staff signout notifications',
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
      ),
      AndroidNotificationChannel(
        'ehc_staff_accept',
        'Staff Shift Claim',
        description: 'Staff shift claim notifications',
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
      ),

      // DEFAULT (use a NEW ID to avoid Android cache issues)
      AndroidNotificationChannel(
        'ehc_default_v2',
        'General',
        description: 'General notifications',
        importance: Importance.high,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
      ),
    ];

    for (final c in channels) {
      await android.createNotificationChannel(c);
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    if (!_initialized) await initialize();

    await _showLocalNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      data: data,
    );
  }

  Future<void> _playNotificationSound(String notificationType) async {
    try {
      String soundAsset;
      switch (notificationType) {
        case 'shift-approved':
          soundAsset = 'sounds/approved.mp3';
          break;
        case 'shift-rejected':
          soundAsset = 'sounds/rejected.mp3';
          break;
        case 'new-shift':
          soundAsset = 'sounds/new_shift.mp3';
          break;
        default:
          soundAsset = 'sounds/notification.mp3';
      }

      await _audioPlayer.play(AssetSource(soundAsset));
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final channelId = _androidChannelForType(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      'EHC Notifications',
      channelDescription:
          'Notifications for shift updates and important alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: _iosSoundForType(type),
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: id,
      body: body,
      notificationDetails: details,
      title: title,

      payload: data == null ? null : jsonEncode(data),
    );
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'shift-approved':
        return const Color(0xFF4CAF50); // Green
      case 'shift-rejected':
        return const Color(0xFFF44336); // Red
      case 'new-shift':
        return const Color(0xFF2196F3); // Blue
      case 'shift-claim-pending':
        return const Color(0xFFFF9800); // Orange
      default:
        return const Color(0xFF9C27B0); // Purple
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen based on payload
  }

  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id: id);
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}

String _androidChannelForType(String type) {
  switch (type) {
    // user types
    case 'shift-approved':
      return 'ehc_shift_approved';
    case 'shift-rejected':
      return 'ehc_shift_rejected';
    case 'new-shift':
      return 'ehc_new_shift';

    // staff/admin types (from your API logs)
    case 'staff-signout':
      return 'ehc_staff_signout';
    case 'staff-acpt-req':
      return 'ehc_staff_accept';

    default:
      return 'ehc_default_v2';
  }
}

String _iosSoundForType(String type) {
  switch (type) {
    case 'shift-approved':
      return 'approved.caf';
    case 'shift-rejected':
      return 'rejected.caf';
    case 'new-shift':
      return 'new_shift.caf';

    case 'staff-signout':
    case 'staff-acpt-req':
      return 'notification.caf';

    default:
      return 'notification.caf';
  }
}
