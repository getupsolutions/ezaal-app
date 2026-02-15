import 'dart:async';
import 'dart:convert';
import 'package:ezaal/core/services/app_badge_count.dart';
import 'package:ezaal/core/services/notification_service.dart';
import 'package:ezaal/core/token_manager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static const _kUnreadCount =
      'unread_count'; // ✅ same key used for UI if needed

  Future<void> startPolling({int intervalSeconds = 30}) async {
    if (_isPolling) return;
    _isPolling = true;

    await _loadDisplayedNotifications();
    await _notificationService.initialize();

    await _checkForNewNotifications();
    onPoll?.call();

    _pollingTimer = Timer.periodic(Duration(seconds: intervalSeconds), (
      _,
    ) async {
      await _checkForNewNotifications();
      onPoll?.call();
    });

    debugPrint(
      '🔔 Notification polling started (every $intervalSeconds seconds)',
    );
  }

  Future<void> _checkForNewNotifications() async {
    try {
      final token = await TokenStorage.getAccessToken();

      if (token == null) {
        await AppBadgeService.clearBadge();
        await _saveUnreadCount(0);
        return;
      }

      debugPrint('✅ Calling: $_apiEndpoint');

      final response = await http.get(
        Uri.parse(_apiEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('✅ Status: ${response.statusCode}');
      debugPrint('✅ Body: ${response.body}');

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
            data: notification,
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

  Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUnreadCount) ?? 0;
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isPolling = false;
    debugPrint('🛑 Notification polling stopped');
  }

  void clearDisplayedNotifications() {
    _displayedNotificationIds.clear();
    _saveDisplayedNotifications();
  }

  bool get isPolling => _isPolling;
}
