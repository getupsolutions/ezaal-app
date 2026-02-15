import 'dart:convert';
import 'package:ezaal/core/token_manager.dart';
import 'package:http/http.dart' as http;
import '../model/staff_notification_model.dart';

class StaffNotificationRemoteDatasource {
  final http.Client client;
  StaffNotificationRemoteDatasource(this.client);

  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<Map<String, String>> _headers() async {
    final token = await TokenStorage.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token ?? ''}',
    };
  }

  Future<int> fetchStaffUnreadCount({String type = 'organiz-add-reqst'}) async {
    final uri = Uri.parse('$baseUrl/get-staff-unread-count?type=$type');
    final res = await client.get(uri, headers: await _headers());

    final decoded = jsonDecode(res.body);
    if (res.statusCode == 200) {
      return int.tryParse(decoded['data']?['count']?.toString() ?? '0') ?? 0;
    }
    throw Exception(decoded['message'] ?? 'Failed to fetch staff unread count');
  }

  Future<List<StaffNotificationModel>> fetchStaffNotifications({
    String type = 'organiz-add-reqst',
    int limit = 30,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/get-staff-notifications?type=$type&limit=$limit&offset=$offset',
    );

    final res = await client.get(uri, headers: await _headers());
    final decoded = jsonDecode(res.body);

    if (res.statusCode == 200) {
      final list = (decoded['data'] as List?) ?? [];
      return list.map((e) => StaffNotificationModel.fromJson(e)).toList();
    }

    throw Exception(
      decoded['message'] ?? 'Failed to fetch staff notifications',
    );
  }
}
