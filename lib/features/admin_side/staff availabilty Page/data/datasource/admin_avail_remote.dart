import 'dart:convert';

import 'package:ezaal/core/services/tokenrefresh_service.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/data/model/admin_avail_model.dart';
import 'package:http/http.dart' as http;

class AvailabilityAdminRemoteDS {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<List<AdminAvailabilityModel>> getAvailabilityRange({
    required String startDate,
    required String endDate,
    int? organiz,
    int? staffId,
  }) async {
    final response = await TokenRefreshService.makeAuthenticatedRequest(
      (token) => http.post(
        // ✅ IMPORTANT: use admin endpoint
        Uri.parse('$baseUrl/admin-get-availability'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'start_date': startDate,
          'end_date': endDate,
          if (organiz != null) 'organiz': organiz,
          if (staffId != null) 'staff_id': staffId,
        }),
      ),
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final list = (decoded['data'] ?? []) as List;
      return list.map((e) => AdminAvailabilityModel.fromJson(e)).toList();
    }

    if (response.statusCode == 404) return [];
    throw Exception('Failed: ${response.statusCode} ${response.body}');
  }
}
