import 'dart:convert';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/features/user_side/timesheet_page/data/model/timesheet_model.dart';
import 'package:http/http.dart' as http;

class TimesheetRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<List<TimesheetModel>> getTimesheet({
    String? startDate,
    String? endDate,
    String? organizationId,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();

    // NOTE: Backend API doesn't filter by date properly, so we only send organization_id
    // Date filtering will be done client-side in the repository
    final Map<String, String> queryParams = {};

    if (organizationId != null && organizationId.isNotEmpty) {
      queryParams['organization_id'] = organizationId;
      print("🏢 Adding organization filter: $organizationId");
    }

    // Build URI with query parameters
    final uri = Uri.parse(
      '$baseUrl/get-timesheet',
    ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    print("=== GET TIMESHEET REQUEST ===");
    print("🌐 Full URL: $uri");
    print("📊 Query Params: $queryParams");
    print("🔑 Has Token: ${accessToken != null && accessToken.isNotEmpty}");

    if (startDate != null && endDate != null) {
      print(
        "⚠️ NOTE: Date filtering ($startDate to $endDate) will be done client-side",
      );
    }

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    print("\n=== GET TIMESHEET RESPONSE ===");
    print("📡 Status Code: ${response.statusCode}");
    print("📦 Response Body: ${response.body}");
    print("==============================\n");

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];

        print("✅ Successfully parsed ${data.length} timesheet records");

        if (data.isEmpty) {
          print("⚠️ WARNING: No timesheet records returned from API");
          if (queryParams.isNotEmpty) {
            print("💡 This might mean:");
            print(
              "   - No records exist for the date range: $startDate to $endDate",
            );
            print("   - The API is not filtering correctly");
            print("   - The date format might be incorrect");
          }
          return [];
        }

        final timesheets = data.map((e) => TimesheetModel.fromJson(e)).toList();

        // Log first and last dates to verify filtering
        if (timesheets.isNotEmpty) {
          print("📋 First record date: ${timesheets.first.date}");
          print("📋 Last record date: ${timesheets.last.date}");
        }

        return timesheets;
      } catch (e) {
        print("❌ Error parsing response: $e");
        print("Stack trace: ${StackTrace.current}");
        rethrow;
      }
    } else if (response.statusCode == 404) {
      print("⚠️ 404: Endpoint not found or no data");
      return [];
    } else {
      final errorMsg = 'Failed to load timesheet: ${response.statusCode}';
      print("❌ $errorMsg");
      print("Response: ${response.body}");
      throw Exception(errorMsg);
    }
  }
}
