import 'dart:convert';
import 'package:ezaal/core/services/tokenrefresh_service.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/savde_admin_shiftmodel.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/save_shift_respo.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/update_shift_attendence_model.dart';
import 'package:http/http.dart' as http;

class AdminShiftRemoteDataSource {
  // Same style as ShiftRemoteDataSource
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<List<ShiftItem>> getShiftsForWeek(
    DateTime weekStart,
    DateTime weekEnd, {
    int? organizationId,
    int? staffId,
    String? status,
  }) async {
    try {
      final startDate = _formatDate(weekStart);
      final endDate = _formatDate(weekEnd);

      final queryParams = <String, String>{
        'start_date': startDate,
        'end_date': endDate,
        'page': '1',
        'per_page': '200',
      };

      if (organizationId != null) {
        queryParams['organization_id'] = organizationId.toString();
      }
      if (staffId != null) {
        queryParams['staff_id'] = staffId.toString();
      }
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(
        '$baseUrl/admin-shifts',
      ).replace(queryParameters: queryParams);

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

  Future<SaveShiftResponse> saveShift(SaveAdminShiftParams params) async {
    try {
      final bool isUpdate = params.id != null;
      final endpoint = isUpdate ? '/admin/update-shift' : '/admin/create-shift';

      final uri = Uri.parse('$baseUrl$endpoint');
      final body = json.encode(params.toJson());

      print('🔄 Saving shift - isUpdate: $isUpdate, endpoint: $endpoint');
      print('📤 Request body: $body');

      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body,
        ),
      );

      print('📥 Save shift status: ${response.statusCode}');
      print('📥 Save shift body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.trim().isEmpty) return const SaveShiftResponse();

        try {
          final decoded = json.decode(response.body);

          // Handle if the response is a Map
          if (decoded is Map<String, dynamic>) {
            final data = decoded['data'];

            // If data is a Map, use it directly
            if (data is Map<String, dynamic>) {
              return SaveShiftResponse.fromJson(data);
            }
            // If data is a List or anything else, return empty response
            else {
              print('⚠️ Data field is not a Map, returning empty response');
              return const SaveShiftResponse();
            }
          }
          // Handle if the entire response is a List (shouldn't happen, but safe fallback)
          else if (decoded is List) {
            print('⚠️ Response is a List, returning empty response');
            return const SaveShiftResponse();
          }
          // Unknown format
          else {
            print('⚠️ Unknown response format, returning empty response');
            return const SaveShiftResponse();
          }
        } catch (parseError) {
          print('❌ Error parsing save shift response: $parseError');
          // Still return success if the status code is 200/201
          return const SaveShiftResponse();
        }
      }

      throw Exception(
        'Failed to save shift: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('❌ Error in saveShift: $e');
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to save shift: $e');
    }
  }

  Future<ShiftMastersDto> getShiftMasters() async {
    try {
      final uri = Uri.parse('$baseUrl/admin-shift-masters');

      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.get(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      print('Shift masters status: ${response.statusCode}');
      print('Shift masters body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to fetch shift masters: '
          '${response.statusCode} - ${response.body}',
        );
      }

      if (response.body.isEmpty || response.body.trim().isEmpty) {
        throw Exception('Empty shift masters response body');
      }

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      final data = decoded['data'] as Map<String, dynamic>;

      return ShiftMastersDto.fromJson(data);
    } catch (e) {
      print('❌ Error fetching shift masters: $e');
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to fetch shift masters: $e');
    }
  }

  Future<void> cancelShift(int shiftId) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/cancel-shift');

      final body = json.encode({'id': shiftId});

      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body,
        ),
      );

      print('Cancel shift status: ${response.statusCode}');
      print('Cancel shift body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to cancel shift: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error cancelling shift: $e');
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to cancel shift: $e');
    }
  }

  Future<void> cancelShiftStaff(int shiftId) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/cancel-shift-staff');

      final body = json.encode({'id': shiftId});

      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body,
        ),
      );

      print('Cancel shift staff status: ${response.statusCode}');
      print('Cancel shift staff body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to cancel shift staff: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error cancelling shift staff: $e');
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to cancel shift staff: $e');
    }
  }

  Future<void> updateShiftAttendance(UpdateShiftAttendanceParams params) async {
    try {
      final uri = Uri.parse('$baseUrl/update-shift-attendance');

      String? _format(DateTime? dt) =>
          dt == null
              ? null
              : dt.toIso8601String().substring(0, 19).replaceFirst('T', ' ');

      final body = <String, dynamic>{
        'id': params.shiftId,
        if (params.signIn != null) 'sigin': _format(params.signIn),
        if (params.signInType != null) 'signintype': params.signInType,
        if (params.signInReason != null) 'signinreason': params.signInReason,
        if (params.signOut != null) 'signout': _format(params.signOut),
        if (params.signOutType != null) 'signouttype': params.signOutType,
        if (params.signOutReason != null) 'signoutreason': params.signOutReason,
        if (params.breakMinutes != null)
          'shiftbreak': params.breakMinutes.toString(),
        if (params.managerName != null) 'mangername': params.managerName,
        if (params.managerDesignation != null)
          'managerdesig': params.managerDesignation,
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

      print('Update shift attendance status: ${response.statusCode}');
      print('Update shift attendance body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update shift attendance: '
          '${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error updating shift attendance: $e');
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to update shift attendance: $e');
    }
  }

  Future<void> updateShiftStatus({
    required int shiftId,
    required bool approve,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/update-shift-status');

      final body = json.encode({
        'id': shiftId,
        'action': approve ? 'approve' : 'unapprove',
      });

      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body,
        ),
      );

      print('Update shift status: ${response.statusCode}');
      print('Update shift status body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to update shift status: '
          '${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error updating shift status: $e');
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to update shift status: $e');
    }
  }

  Future<void> sendOrganizationRosterMail({
    required DateTime startDate,
    required DateTime endDate,
    required int organizationId,
    required bool includeCancelled,
  }) async {
    final uri = Uri.parse('$baseUrl/admin/send-organization-roster-mail');

    final body = {
      'start_date': _formatDate(startDate),
      'end_date': _formatDate(endDate),
      'organization_id': organizationId,
      'include_cancelled': includeCancelled,
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

    if (response.statusCode == 200) return;
    throw Exception('Failed: ${response.statusCode} ${response.body}');
  }

  Future<Map<String, dynamic>> sendStaffConfirmedMail({
    required List<int> shiftIds,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/send-staff-confirmed-mail');

      final body = json.encode({'shift_ids': shiftIds});

      print('📧 Sending staff confirmed mail for shifts: $shiftIds');

      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body,
        ),
      );

      print('Send staff confirmed mail status: ${response.statusCode}');
      print('Send staff confirmed mail body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          return {
            'sent': true,
            'sent_count': shiftIds.length,
            'failed_count': 0,
          };
        }

        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>? ?? {};

        return {
          'sent': data['sent'] ?? true,
          'sent_count': data['sent_count'] ?? shiftIds.length,
          'failed_count': data['failed_count'] ?? 0,
          'results': data['results'] ?? [],
        };
      } else if (response.statusCode == 400) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(decoded['message'] ?? 'Failed to send emails');
      } else {
        throw Exception(
          'Failed to send staff confirmed mail: '
          '${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error sending staff confirmed mail: $e');
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to send staff confirmed mail: $e');
    }
  }

    Future<Map<String, dynamic>> sendStaffAvailableShiftMail({
    required List<int> shiftIds,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/admin/send-staff-available-shift-mail');

      final body = json.encode({'shift_ids': shiftIds});

      print('📧 Sending staff available shift mail for shifts: $shiftIds');

      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          uri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: body,
        ),
      );

      print('Send staff available shift mail status: ${response.statusCode}');
      print('Send staff available shift mail body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.trim().isEmpty) {
          return {'sent': true, 'sent_count': 0, 'failed_count': 0};
        }

        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final data = decoded['data'] as Map<String, dynamic>? ?? {};

        return {
          'sent': data['sent'] ?? true,
          'sent_count': data['sent_count'] ?? 0,
          'failed_count': data['failed_count'] ?? 0,
          'total_eligible': data['total_eligible'] ?? 0,
          'results': data['results'] ?? [],
        };
      } else if (response.statusCode == 400) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        throw Exception(decoded['message'] ?? 'Failed to send emails');
      } else {
        throw Exception(
          'Failed to send staff available shift mail: '
          '${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error sending staff available shift mail: $e');
      if (e.toString().contains('Session expired')) rethrow;
      throw Exception('Failed to send staff available shift mail: $e');
    }
  }

  String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
