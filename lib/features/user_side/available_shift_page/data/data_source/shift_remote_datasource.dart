import 'dart:convert';
import 'package:ezaal/core/token_manager.dart';
import 'package:http/http.dart' as http;
import '../models/shift_model.dart';

class ShiftRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public/';

  Future<List<ShiftModel>> getAvailableShifts() async {
    final accessToken = await TokenStorage.getAccessToken();

    print('Fetching shifts with token: ${accessToken?.substring(0, 20)}...');

    final response = await http.get(
      // ✅ Changed back to GET
      Uri.parse('$baseUrl/available-shifts'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('Response headers: ${response.headers}');

    if (response.statusCode == 200) {
      // Handle empty response
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
  }

  Future<void> claimShift(int shiftId) async {
    final accessToken = await TokenStorage.getAccessToken();

    final response = await http.post(
      Uri.parse('$baseUrl/claim-shift'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'requestID': shiftId}),
    );

    print('Claim shift response status: ${response.statusCode}');
    print('Claim shift response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else {
      throw Exception('Failed to claim shift: ${response.statusCode}');
    }
  }
}
