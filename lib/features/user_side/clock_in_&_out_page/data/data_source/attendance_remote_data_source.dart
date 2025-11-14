import 'dart:convert';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/data/models/slot_model.dart';
import 'package:http/http.dart' as http;

class AttendanceRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<List<SlotModel>> getSlots() async {
    final accessToken = await TokenStorage.getAccessToken();

    final response = await http.get(
      Uri.parse('$baseUrl/getslot'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("=== GET SLOTS DEBUG ===");
    print("URL: $baseUrl/getslot");
    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");
    print("======================");

    if (response.statusCode == 200 || response.statusCode == 404) {
      try {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];

        if (data.isEmpty) {
          print("⚠️ No slots returned from API");
          return [];
        }

        return data.map((e) => SlotModel.fromJson(e)).toList();
      } catch (e) {
        print("Error parsing response: $e");
        return [];
      }
    } else {
      throw Exception(
        'Failed to load slots: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> clockIn({
    required String requestID,
    required String inTime,
    String? notes,
    required String signintype,
    String? userLocation,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();

    // Match PHP backend expected fields
    final payload = {
      'requestID': requestID,
      'inTime': inTime,
      'signintype': signintype,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (userLocation != null && userLocation.isNotEmpty)
        'userLocation': userLocation,
    };

    print("=== CLOCK IN DEBUG ===");
    print("Payload: ${jsonEncode(payload)}");
    print("=====================");

    final response = await http.post(
      Uri.parse('$baseUrl/clock-in'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print("=== CLOCK IN RESPONSE ===");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");
    print("========================");

    if (response.statusCode != 200) {
      print(response.body);

      throw Exception(
        'Failed to clock in: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> clockOut({
    required String requestID,
    required String outTime,
    String? shiftbreak,
    String? notes,
    required String signouttype,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();

    final payload = {
      'requestID': requestID,
      'outTime': outTime,
      'signouttype': signouttype,
      if (shiftbreak != null && shiftbreak.isNotEmpty) 'shiftbreak': shiftbreak,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    print("=== CLOCK OUT DEBUG ===");
    print("URL: $baseUrl/clock-out");
    print("Payload: ${jsonEncode(payload)}");
    print("======================");

    final response = await http.post(
      Uri.parse('$baseUrl/clock-out'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    print("=== CLOCK OUT RESPONSE ===");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");
    print("Headers: ${response.headers}");
    print("=========================");

    // Accept both 200 and 404 since PHP returns 404 on success (based on your backend code)
    if (response.statusCode == 200 || response.statusCode == 404) {
      try {
        final jsonData = jsonDecode(response.body);
        final message = jsonData['message'] ?? '';

        // Check if the message indicates success
        if (message.toLowerCase().contains('success') ||
            message.toLowerCase().contains('logged')) {
          return; // Success
        } else {
          throw Exception('Clock out failed: $message');
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Clock out failed: Unable to parse response');
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Clock out failed: $errorMessage');
      } catch (e) {
        throw Exception(
          'Clock out failed: ${response.statusCode} ${response.body}',
        );
      }
    }
  }
}
