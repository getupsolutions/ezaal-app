import 'dart:convert';
import 'dart:typed_data';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';
import 'package:http/http.dart' as http;

class ManagerInfoRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<void> submitManagerInfo({
    required String requestID,
    required String managerName,
    required String managerDesignation,
    required Uint8List signatureBytes,
    bool isRetry = false, // ✅ Add flag to prevent infinite recursion
  }) async {
    // Check if online (only if not a retry from sync service)
    if (!isRetry) {
      final isOnline = await OfflineQueueService.isOnline();

      if (!isOnline) {
        // Queue for later with signature
        await OfflineQueueService.queueOperation(OperationType.managerInfo, {
          'requestID': requestID,
          'managerName': managerName,
          'managerDesignation': managerDesignation,
        }, signatureBytes: signatureBytes);
        print('📥 Manager info queued for offline sync');
        return; // Return successfully - operation queued
      }
    }

    // Online - proceed with API call
    final accessToken = await TokenStorage.getAccessToken();

    print("=== SUBMIT MANAGER INFO DEBUG ===");
    print("URL: $baseUrl/add-manager");
    print("Request ID: $requestID");
    print("Manager Name: $managerName");
    print("Designation: $managerDesignation");
    print("Signature size: ${signatureBytes.length} bytes");

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/add-manager'),
      );

      request.headers.addAll({'Authorization': 'Bearer $accessToken'});

      request.fields['requestID'] = requestID;
      request.fields['mangername'] = managerName;
      request.fields['managerdesig'] = managerDesignation;

      request.files.add(
        http.MultipartFile.fromBytes(
          'attachment',
          signatureBytes,
          filename: 'signature_${DateTime.now().millisecondsSinceEpoch}.png',
        ),
      );

      print("Sending multipart request...");

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Connection timeout - request took too long');
        },
      );

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
            return;
          } else {
            throw Exception('Submit manager info failed: $message');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception(
            'Submit manager info failed: Unable to parse response',
          );
        }
      } else {
        throw Exception(
          'Submit manager info failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Manager info API call failed: $e');

      // Queue the operation if API call fails (only if not already a retry)
      if (!isRetry) {
        await OfflineQueueService.queueOperation(OperationType.managerInfo, {
          'requestID': requestID,
          'managerName': managerName,
          'managerDesignation': managerDesignation,
        }, signatureBytes: signatureBytes);

        print('📥 Manager info queued due to API failure');
        return; // Don't rethrow - operation has been queued successfully
      }

      // If this is a retry, rethrow the error
      rethrow;
    }
  }
}
