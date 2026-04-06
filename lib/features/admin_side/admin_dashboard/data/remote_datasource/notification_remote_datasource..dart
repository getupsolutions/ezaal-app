import 'dart:convert';
import 'package:ezaal/core/services/tokenrefresh_service.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/data/model/notification_model.dart';
import 'package:http/http.dart' as http;

class NotificationRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  bool _looksLikeHtml(String body) {
    final text = body.trim().toLowerCase();
    return text.startsWith('<!doctype html') ||
        text.startsWith('<html') ||
        text.startsWith('<br') ||
        text.contains('<b>fatal error</b>');
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.get(
          Uri.parse('$baseUrl/get-notifications'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('Notifications response status: ${response.statusCode}');
      print('Notifications response body: ${response.body}');

      if (_looksLikeHtml(response.body)) {
        throw Exception('Backend returned HTML instead of JSON');
      }

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) return [];

        final decoded = jsonDecode(response.body);
        final List dataList = decoded['data'] ?? [];
        return dataList.map((e) => NotificationModel.fromJson(e)).toList();
      }

      if (response.statusCode == 404) return [];

      throw Exception('Failed to fetch notifications: ${response.statusCode}');
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.get(
          Uri.parse('$baseUrl/get-unread-count'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('Unread count status: ${response.statusCode}');
      print('Unread count body: ${response.body}');

      if (_looksLikeHtml(response.body)) {
        return 0;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return int.tryParse('${data['data']['unread_count'] ?? 0}') ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Error fetching unread count: $e');
      return 0;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final response = await TokenRefreshService.makeAuthenticatedRequest(
      (token) => http.post(
        Uri.parse('$baseUrl/mark-notification-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'notification_id': notificationId}),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  Future<void> markAllAsRead() async {
    final response = await TokenRefreshService.makeAuthenticatedRequest(
      (token) => http.post(
        Uri.parse('$baseUrl/mark-all-notifications-read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all notifications as read');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    final response = await TokenRefreshService.makeAuthenticatedRequest(
      (token) => http.post(
        Uri.parse('$baseUrl/delete-notification'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'notification_id': notificationId}),
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete notification');
    }
  }
}
