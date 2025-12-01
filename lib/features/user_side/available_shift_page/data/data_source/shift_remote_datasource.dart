import 'dart:convert';
import 'package:ezaal/core/services/tokenrefresh_service.dart';
import 'package:http/http.dart' as http;
import '../models/shift_model.dart';

class ShiftRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<List<ShiftModel>> getAvailableShifts() async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.get(
          Uri.parse('$baseUrl/available-shifts'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('Empty response body - returning empty list');
          return [];
        }

        try {
          final data = jsonDecode(response.body);
          print('Decoded data: $data');

          if (data == null || data['data'] == null) {
            print('No data field - returning empty list');
            return [];
          }

          final dataList = data['data'] as List;
          if (dataList.isEmpty) {
            print('Empty data list - returning empty list');
            return [];
          }

          final shifts = dataList.map((e) => ShiftModel.fromJson(e)).toList();
          print('Successfully parsed ${shifts.length} shifts');
          return shifts;
        } catch (e) {
          print('Error parsing response: $e');
          return [];
        }
      } else if (response.statusCode == 404) {
        print('404 response - no shifts available');
        return [];
      } else {
        throw Exception(
          'Failed to fetch shifts: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Error fetching shifts: $e');

      if (e.toString().contains('Session expired')) {
        rethrow;
      }

      throw Exception('Failed to fetch shifts: $e');
    }
  }

  /// Claim a shift and automatically send notification to admin
  /// The backend handles notification creation automatically
  Future<void> claimShift(int shiftId) async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          Uri.parse('$baseUrl/claim-shift'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'requestID': shiftId}),
        ),
      );

      print('✅ Claim shift response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Shift claimed successfully - notification sent automatically');
        return;
      } else {
        throw Exception('Failed to claim shift: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error claiming shift: $e');

      if (e.toString().contains('Session expired')) {
        rethrow;
      }

      throw Exception('Failed to claim shift: $e');
    }
  }
}
