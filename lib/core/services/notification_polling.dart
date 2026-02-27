import 'dart:async';
import 'dart:convert';

import 'package:ezaal/core/services/app_badge_count.dart';
import 'package:ezaal/core/services/background_service.dart';
import 'package:ezaal/core/services/notification_service.dart';
import 'package:ezaal/core/token_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:io' show Platform;

class NotificationPollingService {
  static final NotificationPollingService _instance =
      NotificationPollingService._internal();
  factory NotificationPollingService() => _instance;
  NotificationPollingService._internal();

  VoidCallback? onPoll;
  Timer? _pollingTimer;
  bool _isPolling = false;

  final LocalNotificationService _notificationService =
      LocalNotificationService();
  Set<int> _displayedNotificationIds = {};

  final String _apiEndpoint =
      'https://app.ezaalhealthcare.com.au/api/v1/public/get-notifications';

  static const _kUnreadCount = 'unread_count';

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Call once after login. Starts both foreground polling AND registers
  /// the Workmanager background task.
  Future<void> startPolling({int intervalSeconds = 30}) async {
    if (_isPolling) return;
    _isPolling = true;

    await _loadDisplayedNotifications();
    await _notificationService.initialize();

    // ── Register Workmanager background task ──────────────────────────────
    await _registerBackgroundTask();

    // ── Foreground polling (while app is open) ────────────────────────────
    await _checkForNewNotifications();
    onPoll?.call();

    _pollingTimer = Timer.periodic(Duration(seconds: intervalSeconds), (
      _,
    ) async {
      await _checkForNewNotifications();
      onPoll?.call();
    });

    debugPrint(
      '🔔 Polling started (foreground: ${intervalSeconds}s | background: Workmanager)',
    );
  }

  /// Call on logout — stops foreground polling AND cancels background task.
  Future<void> stopPolling() async {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;

    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await Workmanager().cancelByUniqueName(BackgroundTaskNames.periodicPoll);
    }

    debugPrint('🛑 Notification polling stopped');
  }

  void clearDisplayedNotifications() {
    _displayedNotificationIds.clear();
    _saveDisplayedNotifications();
  }

  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUnreadCount) ?? 0;
  }

  bool get isPolling => _isPolling;

  // ── Background task registration ────────────────────────────────────────────

  Future<void> _registerBackgroundTask() async {
    if (kIsWeb) return;
    if (!(Platform.isAndroid || Platform.isIOS)) return;

    await Workmanager().initialize(
      callbackDispatcher, // top-level function in background_service.dart
      isInDebugMode: false,
    );

    // Android supports true periodic tasks (min 15 min enforced by OS)
    // iOS uses BGAppRefreshTask (requires capability in Xcode)
    await Workmanager().registerPeriodicTask(
      BackgroundTaskNames.periodicPoll,
      BackgroundTaskNames.periodicPoll,
      frequency: const Duration(minutes: 15),
      initialDelay: const Duration(seconds: 10),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );

    debugPrint('✅ Workmanager background task registered (15 min interval)');
  }

  // ── Foreground polling ──────────────────────────────────────────────────────

  Future<void> _checkForNewNotifications() async {
    try {
      final token = await TokenStorage.getAccessToken();

      if (token == null) {
        await AppBadgeService.clearBadge();
        await _saveUnreadCount(0);
        return;
      }

      final response = await http
          .get(
            Uri.parse(_apiEndpoint),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('❌ Notification API error: ${response.statusCode}');
        return;
      }

      final decoded = json.decode(response.body);
      final List notifications = decoded['data'] ?? [];

      int unreadCount = 0;

      for (final notification in notifications) {
        final int notificationId =
            int.tryParse(notification['id'].toString()) ?? 0;
        final int rd = int.tryParse(notification['rd'].toString()) ?? 1;
        final bool isUnread = rd == 0;

        if (isUnread) unreadCount++;

        if (isUnread && !_displayedNotificationIds.contains(notificationId)) {
          await _notificationService.showNotification(
            id: notificationId,
            title: _getNotificationTitle(notification['type']),
            body: notification['notification'] ?? '',
            type: notification['type'] ?? 'default',
            data: Map<String, dynamic>.from(notification),
          );
          _displayedNotificationIds.add(notificationId);
          await _saveDisplayedNotifications();
        }
      }

      await _saveUnreadCount(unreadCount);
      await AppBadgeService.setUnreadCount(unreadCount);
    } catch (e) {
      debugPrint('❌ Error checking notifications: $e');
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _getNotificationTitle(String? type) {
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

  Future<void> _loadDisplayedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('displayed_notification_ids');
    if (ids != null) {
      _displayedNotificationIds = ids.map((e) => int.tryParse(e) ?? 0).toSet();
    }
  }

  Future<void> _saveDisplayedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'displayed_notification_ids',
      _displayedNotificationIds.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _saveUnreadCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kUnreadCount, count);
  }
}
