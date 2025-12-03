import 'dart:convert';
import 'package:ezaal/core/services/tokenrefresh_service.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/data/model/notification_model.dart';
import 'package:http/http.dart' as http;

class NotificationRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.get(
          Uri.parse('$baseUrl/get-notifications'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Notifications response status: ${response.statusCode}');
      print('Notifications response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          return [];
        }

        final data = jsonDecode(response.body);

        if (data == null || data['data'] == null) {
          return [];
        }

        final dataList = data['data'] as List;
        if (dataList.isEmpty) {
          return [];
        }

        return dataList.map((e) => NotificationModel.fromJson(e)).toList();
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception(
          'Failed to fetch notifications: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Error fetching notifications: $e');
      if (e.toString().contains('Session expired')) {
        rethrow;
      }
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
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['unread_count'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('❌ Error fetching unread count: $e');
      return 0;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          Uri.parse('$baseUrl/mark-notification-read'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'notification_id': notificationId}),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark notification as read');
      }
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          Uri.parse('$baseUrl/mark-all-notifications-read'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark all notifications as read');
      }
    } catch (e) {
      print('❌ Error marking all notifications as read: $e');
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          Uri.parse('$baseUrl/delete-notification'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'notification_id': notificationId}),
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete notification');
      }
    } catch (e) {
      print('❌ Error deleting notification: $e');
      throw Exception('Failed to delete notification: $e');
    }
  }
}
