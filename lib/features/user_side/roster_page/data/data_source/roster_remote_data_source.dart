import 'dart:convert';
import 'package:ezaal/core/token_manager.dart';
import 'package:http/http.dart' as http;
import '../models/roster_model.dart';

class RosterRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  RosterRemoteDataSource(); // ✅ Remove token from constructor

  // ✅ Helper method to get token
  Future<String> _getToken() async {
    final token = await TokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('No authentication token found. Please login again.');
    }

    // Validate token format
    if (token.split('.').length != 3) {
      throw Exception(
        'Invalid authentication token format. Please login again.',
      );
    }

    return token;
  }

  Future<List<RosterModel>> getRoster() async {
    // ✅ Get token dynamically
    final token = await _getToken();

    print('=== ROSTER API REQUEST ===');
    print('URL: $baseUrl/get-roster');
    print('Token length: ${token.length}');
    print('Token segments count: ${token.split('.').length}');

    final response = await http.get(
      Uri.parse('$baseUrl/get-roster'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('=== END ROSTER API REQUEST ===');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Roster API returned empty response');
      }

      final decoded = jsonDecode(response.body);

      if (decoded['data'] == null) {
        throw Exception('Roster API response missing data field');
      }

      final jsonList = decoded['data'] as List;
      print('Roster count: ${jsonList.length}');

      return jsonList.map((e) => RosterModel.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      // Clear invalid tokens
      await TokenStorage.clearTokens();
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception(
        'Failed to load roster: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<List<RosterModel>> getRosterCalendar() async {
    // ✅ Get token dynamically
    final token = await _getToken();

    print('=== ROSTER CALENDAR API REQUEST ===');
    print('URL: $baseUrl/get-roster-calender');

    final response = await http.get(
      Uri.parse('$baseUrl/get-roster-calender'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('=== END ROSTER CALENDAR API REQUEST ===');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        throw Exception('Roster calendar API returned empty response');
      }

      final decoded = jsonDecode(response.body);

      if (decoded['data'] == null) {
        throw Exception('Roster calendar API response missing data field');
      }

      final jsonList = decoded['data'] as List;
      return jsonList.map((e) => RosterModel.fromJson(e)).toList();
    } else if (response.statusCode == 401) {
      // Clear invalid tokens
      await TokenStorage.clearTokens();
      throw Exception('Authentication failed. Please login again.');
    } else {
      throw Exception(
        'Failed to load roster calendar: ${response.statusCode} ${response.body}',
      );
    }
  }
}
