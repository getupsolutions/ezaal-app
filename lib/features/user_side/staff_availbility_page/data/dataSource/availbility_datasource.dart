import 'dart:convert';
import 'package:ezaal/core/services/tokenrefresh_service.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/data/model/availability_model.dart';
import 'package:http/http.dart' as http;

class AvailabilityRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  /// Fetch availability within a date range
  /// Body: { start_date: "YYYY-MM-DD", end_date: "YYYY-MM-DD" }
  Future<List<AvailabilityModel>> getAvailability({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          Uri.parse('$baseUrl/get-availability'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'start_date': startDate, 'end_date': endDate}),
        ),
      );

      print('📌 getAvailability status: ${response.statusCode}');
      print('📌 getAvailability body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          print('Empty response body - returning empty list');
          return [];
        }

        try {
          final decoded = jsonDecode(response.body);

          if (decoded == null || decoded['data'] == null) {
            print('No data field - returning empty list');
            return [];
          }

          final list = decoded['data'] as List;
          if (list.isEmpty) return [];

          final items = list.map((e) => AvailabilityModel.fromJson(e)).toList();
          print('✅ Parsed ${items.length} availability rows');
          return items;
        } catch (e) {
          print('❌ Error parsing availability response: $e');
          return [];
        }
      }

      if (response.statusCode == 404) {
        print('404 response - no availability found');
        return [];
      }

      throw Exception(
        'Failed to fetch availability: ${response.statusCode} - ${response.body}',
      );
    } catch (e) {
      print('❌ Error fetching availability: $e');

      // Keep your session-expired behavior consistent
      if (e.toString().contains('Session expired')) {
        rethrow;
      }

      throw Exception('Failed to fetch availability: $e');
    }
  }

  /// Save (insert/update) availability for a date and shift
  /// Body: { dateof: "YYYY-MM-DD", shift: "AM"|"PM"|"NIGHT", fromtime, totime, notes }
  Future<void> saveAvailability(AvailabilityModel model) async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          Uri.parse('$baseUrl/save-availability'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(model.toJson()),
        ),
      );

      print('✅ saveAvailability status: ${response.statusCode}');
      print('saveAvailability body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      // Try to extract backend message
      String msg = 'Failed to save availability';
      try {
        final decoded = jsonDecode(response.body);
        msg = (decoded?['message'] ?? msg).toString();
      } catch (_) {}

      if (response.statusCode == 409) {
        // Conflict with claimed/completed shift
        throw Exception(msg);
      }

      throw Exception('$msg (${response.statusCode})');
    } catch (e) {
      print('❌ Error saving availability: $e');

      if (e.toString().contains('Session expired')) {
        rethrow;
      }

      throw Exception('Failed to save availability: $e');
    }
  }

  /// Edit availability - uses same endpoint as save (upsert)
  Future<void> editAvailability(AvailabilityModel model) async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          Uri.parse('$baseUrl/edit-availability'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(model.toJson()),
        ),
      );

      print('✏️ editAvailability status: ${response.statusCode}');
      print('editAvailability body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      String msg = 'Failed to edit availability';
      try {
        final decoded = jsonDecode(response.body);
        msg = (decoded?['message'] ?? msg).toString();
      } catch (_) {}

      if (response.statusCode == 409) {
        throw Exception(msg);
      }

      throw Exception('$msg (${response.statusCode})');
    } catch (e) {
      print('❌ Error editing availability: $e');

      if (e.toString().contains('Session expired')) {
        rethrow;
      }

      throw Exception('Failed to edit availability: $e');
    }
  }

  /// Delete availability for a specific date and shift
  /// Body: { dateof: "YYYY-MM-DD", shift: "AM"|"PM"|"NIGHT" }
  Future<void> deleteAvailability({
    required String dateof,
    required String shift,
  }) async {
    try {
      final response = await TokenRefreshService.makeAuthenticatedRequest(
        (token) => http.post(
          Uri.parse('$baseUrl/delete-availability'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'dateof': dateof,
            'shift': shift, // ✅ Now includes shift parameter
          }),
        ),
      );

      print('🗑 deleteAvailability status: ${response.statusCode}');
      print('deleteAvailability body: ${response.body}');

      if (response.statusCode == 200) return;

      String msg = 'Failed to delete availability';
      try {
        final decoded = jsonDecode(response.body);
        msg = (decoded?['message'] ?? msg).toString();
      } catch (_) {}

      if (response.statusCode == 404) {
        // Treat as success - already deleted
        print('⚠️ 404 on delete - treating as success (already deleted)');
        return;
      }

      throw Exception('$msg (${response.statusCode})');
    } catch (e) {
      print('❌ Error deleting availability: $e');

      if (e.toString().contains('Session expired')) {
        rethrow;
      }

      throw Exception('Failed to delete availability: $e');
    }
  }
}
