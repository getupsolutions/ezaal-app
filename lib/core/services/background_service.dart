import 'dart:convert';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// ─── MUST be a top-level function ────────────────────────────────────────────
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      await BackgroundNotificationTask.run();
    } catch (e) {
      print('❌ Background task error: $e');
    }
    return Future.value(true);
  });
}

// ─── Workmanager task name constants ─────────────────────────────────────────
class BackgroundTaskNames {
  static const periodicPoll = 'ehc_notification_poll';
  static const oneTimePoll = 'ehc_notification_poll_once';
}

// ─── Shared prefs keys ───────────────────────────────────────────────────────
class _Keys {
  static const token = 'access_token';
  static const displayedIds = 'displayed_notification_ids';
  static const unreadCount = 'unread_count';
}

// ─── Core background work ────────────────────────────────────────────────────
class BackgroundNotificationTask {
  static const _apiEndpoint =
      'https://app.ezaalhealthcare.com.au/api/v1/public/get-notifications';

  static Future<void> run() async {
    // 1. Read token from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_Keys.token);
    if (token == null || token.isEmpty) return;

    // 2. Fetch notifications
    final response = await http
        .get(
          Uri.parse(_apiEndpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) return;

    final decoded = json.decode(response.body);
    final List data = decoded['data'] ?? [];

    // 3. Load already-displayed IDs
    final storedIds = prefs.getStringList(_Keys.displayedIds) ?? [];
    final displayedIds = storedIds.map((e) => int.tryParse(e) ?? 0).toSet();

    int unreadCount = 0;

    // 4. Init notifications plugin
    final plugin = FlutterLocalNotificationsPlugin();

    if (!kIsWeb) {
      if (Platform.isAndroid) {
        // ✅ FIX: use named parameter 'settings:'
        await plugin.initialize(
          settings: const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          ),
        );
        await _ensureChannels(plugin);
      } else if (Platform.isIOS) {
        // ✅ FIX: use named parameter 'settings:'
        await plugin.initialize(
          settings: const InitializationSettings(
            iOS: DarwinInitializationSettings(
              requestAlertPermission: false,
              requestBadgePermission: false,
              requestSoundPermission: false,
            ),
          ),
        );
      }
    }

    // 5. Show new unread notifications
    for (final n in data) {
      final int id = int.tryParse(n['id']?.toString() ?? '0') ?? 0;
      final int rd = int.tryParse(n['rd']?.toString() ?? '1') ?? 1;
      final bool isUnread = rd == 0;

      if (isUnread) unreadCount++;

      if (isUnread && !displayedIds.contains(id)) {
        await _showNotification(
          plugin: plugin,
          id: id,
          title: _titleForType(n['type']),
          body: n['notification'] ?? '',
          type: n['type'] ?? 'default',
          data: Map<String, dynamic>.from(n),
        );
        displayedIds.add(id);
      }
    }

    // 6. Persist updated state
    await prefs.setStringList(
      _Keys.displayedIds,
      displayedIds.map((e) => e.toString()).toList(),
    );
    await prefs.setInt(_Keys.unreadCount, unreadCount);
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  static Future<void> _showNotification({
    required FlutterLocalNotificationsPlugin plugin,
    required int id,
    required String title,
    required String body,
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final channelId = _channelForType(type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      'EHC Notifications',
      channelDescription: 'Shift and healthcare updates',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: _iosSoundForType(type),
    );

    // ✅ FIX: plugin.show() uses positional args for id/title/body,
    //         NotificationDetails uses named params
    await plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: jsonEncode(data),
    );
  }

  static Future<void> _ensureChannels(
    FlutterLocalNotificationsPlugin plugin,
  ) async {
    // ✅ FIX: must be one single expression with the generic on the method call
    final android =
        plugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (android == null) return;

    final channels = [
      const AndroidNotificationChannel(
        'ehc_shift_approved',
        'Shift Approved',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('approved'),
      ),
      const AndroidNotificationChannel(
        'ehc_shift_rejected',
        'Shift Rejected',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('rejected'),
      ),
      const AndroidNotificationChannel(
        'ehc_new_shift',
        'New Shift',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('new_shift'),
      ),
      const AndroidNotificationChannel(
        'ehc_staff_signout',
        'Staff Signout',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      ),
      const AndroidNotificationChannel(
        'ehc_staff_accept',
        'Staff Shift Claim',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      ),
      const AndroidNotificationChannel(
        'ehc_default_v2',
        'General',
        importance: Importance.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      ),
    ];

    for (final c in channels) {
      await android.createNotificationChannel(c);
    }
  }

  static String _channelForType(String type) {
    switch (type) {
      case 'shift-approved':
        return 'ehc_shift_approved';
      case 'shift-rejected':
        return 'ehc_shift_rejected';
      case 'new-shift':
        return 'ehc_new_shift';
      case 'staff-signout':
        return 'ehc_staff_signout';
      case 'staff-acpt-req':
        return 'ehc_staff_accept';
      default:
        return 'ehc_default_v2';
    }
  }

  static String _iosSoundForType(String type) {
    switch (type) {
      case 'shift-approved':
        return 'approved.caf';
      case 'shift-rejected':
        return 'rejected.caf';
      case 'new-shift':
        return 'new_shift.caf';
      default:
        return 'notification.caf';
    }
  }

  static String _titleForType(String? type) {
    switch (type) {
      case 'shift-approved':
        return 'Shift Approved ✓';
      case 'shift-rejected':
        return 'Shift Rejected';
      case 'new-shift':
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
}
