import 'dart:async';
import 'dart:ui';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';

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
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;

    // Request notification permission for Android 13+
    await _requestPermission();

    // Initialize local notifications
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    await _createNotificationChannel();

    _initialized = true;
    print('Local Notification Service initialized');
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ehc_notifications',
      'EHC Notifications',
      description: 'Notifications for shift updates and important alerts',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.createNotificationChannel(channel);
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    if (!_initialized) {
      await initialize();
    }

    // Play notification sound
    await _playNotificationSound(type);

    // Show local notification
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
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'ehc_notifications',
      'EHC Notifications',
      channelDescription:
          'Notifications for shift updates and important alerts',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      color: _getColorForType(type),
      icon: '@mipmap/ic_launcher',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: data?.toString(),
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
