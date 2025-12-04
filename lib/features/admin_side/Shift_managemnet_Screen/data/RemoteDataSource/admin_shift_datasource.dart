import 'dart:convert';
import 'package:ezaal/core/services/tokenrefresh_service.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:http/http.dart' as http;

class AdminShiftRemoteDataSource {
  // Same style as ShiftRemoteDataSource
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<List<ShiftItem>> getShiftsForWeek(
    DateTime weekStart,
    DateTime weekEnd, {
    int? organizationId,
  }) async {
    try {
      final startDate = _formatDate(weekStart);
      final endDate = _formatDate(weekEnd);

      final uri = Uri.parse('$baseUrl/admin-shifts').replace(
        queryParameters: <String, String>{
          'start_date': startDate,
          'end_date': endDate,
          if (organizationId != null)
            'organization_id': organizationId.toString(),
          'page': '1',
          'per_page': '200',
        },
      );

      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Admin shifts status: ${response.statusCode}');
      print('Admin shifts body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('Empty admin shift response body - returning empty list');
          return [];
        }

        try {
          final decoded = json.decode(response.body);

          if (decoded == null || decoded['data'] == null) {
            print('No data field in admin shifts - returning empty list');
            return [];
          }

          final List dataList = decoded['data'] as List;
          if (dataList.isEmpty) {
            print('Empty admin shift data list - returning empty list');
            return [];
          }

          final shifts =
              dataList
                  .map((e) => ShiftItem.fromJson(e as Map<String, dynamic>))
                  .toList();

          print('✅ Admin shifts parsed: ${shifts.length}');
          return shifts;
        } catch (e) {
          print('Error parsing admin shifts response: $e');
          return [];
        }
      } else if (response.statusCode == 404) {
        print('404 admin shifts - no shifts found');
        return [];
      } else {
        throw Exception(
          'Failed to fetch admin shifts: '
          '${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error fetching admin shifts: $e');

      // Let session-expired bubble up like in ShiftRemoteDataSource
      if (e.toString().contains('Session expired')) {
        rethrow;
      }

      throw Exception('Failed to fetch admin shifts: $e');
    }
  }

  Future<void> approvePendingShiftClaims({
    DateTime? startDate,
    DateTime? endDate,
    int? organizationId,
    int? staffId,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/admin-approve-pending-claims');

      final body = <String, dynamic>{
        if (startDate != null) 'start_date': _formatDate(startDate),
        if (endDate != null) 'end_date': _formatDate(endDate),
        if (organizationId != null) 'organization_id': organizationId,
        if (staffId != null) 'staff_id': staffId,
      };

      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(body),
        ),
      );

      print('Approve pending claims status: ${response.statusCode}');
      print('Approve pending claims body: ${response.body}');

      if (response.statusCode == 200) {
        // Optionally parse counts from response
        return;
      } else if (response.statusCode == 404) {
        // No pending claims to approve = not really an error
        return;
      } else {
        throw Exception(
          'Failed to approve pending claims: '
          '${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error approving pending claims: $e');

      if (e.toString().contains('Session expired')) {
        rethrow;
      }

      throw Exception('Failed to approve pending claims: $e');
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
