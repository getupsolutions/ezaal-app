import 'dart:convert';
import 'dart:typed_data';
import 'package:ezaal/core/token_manager.dart';
import 'package:http/http.dart' as http;

class ManagerInfoRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<void> submitManagerInfo({
    required String requestID,
    required String managerName,
    required String managerDesignation,
    required Uint8List signatureBytes,
  }) async {
    final accessToken = await TokenStorage.getAccessToken();

    print("=== SUBMIT MANAGER INFO DEBUG ===");
    print("URL: $baseUrl/add-manager");
    print("Request ID: $requestID");
    print("Manager Name: $managerName");
    print("Designation: $managerDesignation");
    print("Signature size: ${signatureBytes.length} bytes");

    // Create multipart request for file upload
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/add-manager'),
    );

    // Add headers
    request.headers.addAll({'Authorization': 'Bearer $accessToken'});

    // Add form fields
    request.fields['requestID'] = requestID;
    request.fields['mangername'] = managerName;
    request.fields['managerdesig'] = managerDesignation;

    // Add signature file
    request.files.add(
      http.MultipartFile.fromBytes(
        'attachment', // This matches your PHP $_FILES['attachment']
        signatureBytes,
        filename: 'signature_${DateTime.now().millisecondsSinceEpoch}.png',
      ),
    );

    print("Sending multipart request...");
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print("=== MANAGER INFO RESPONSE ===");
    print("Status: ${response.statusCode}");
    print("Body: ${response.body}");
    print("============================");

    if (response.statusCode == 200) {
      try {
        final jsonData = jsonDecode(response.body);
        final message = jsonData['message'] ?? '';

        if (message.toLowerCase().contains('success')) {
          return; // Success
        } else {
          throw Exception('Submit manager info failed: $message');
        }
      } catch (e) {
        if (e is Exception) rethrow;
        throw Exception('Submit manager info failed: Unable to parse response');
      }
    } else {
      try {
        final errorBody = jsonDecode(response.body);
        final errorMessage = errorBody['message'] ?? 'Unknown error';
        throw Exception('Submit manager info failed: $errorMessage');
      } catch (e) {
        throw Exception(
          'Submit manager info failed: ${response.statusCode} ${response.body}',
        );
      }
    }
  }
}
