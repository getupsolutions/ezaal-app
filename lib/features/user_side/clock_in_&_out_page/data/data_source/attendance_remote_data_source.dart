import 'dart:async';
import 'dart:convert';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/data/models/slot_model.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AttendanceRemoteDataSource {
  final String baseUrl = 'https://app.ezaalhealthcare.com.au/api/v1/public';

  Future<List<SlotModel>> getSlots() async {
    try {
      // ✅ 1) Check connectivity first
      final isOnline = await OfflineQueueService.isOnline();

      if (!isOnline) {
        debugPrint('📴 Device offline - loading cached slots');
        final cached = await OfflineQueueService.getCachedSlots();

        if (cached != null && cached.isNotEmpty) {
          return cached.map((e) => SlotModel.fromJson(e)).toList();
        } else {
          debugPrint('⚠️ No cached slots available');
          return [];
        }
      }

      // ✅ 2) Online - fetch from API
      final accessToken = await TokenStorage.getAccessToken();

      final response = await http
          .get(
            Uri.parse('$baseUrl/getslot'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () async {
              // ⏱️ On timeout, *actually* use cached data if present
              debugPrint('⏱️ API timeout - loading cached slots');
              final cached = await OfflineQueueService.getCachedSlots();
              if (cached != null && cached.isNotEmpty) {
                debugPrint('📦 Using cached slots due to timeout');
                return http.Response(jsonEncode({'data': cached}), 200);
              }
              // No cache → propagate timeout
              throw TimeoutException(
                'Connection timeout and no cache available',
              );
            },
          );

      print("=== GET SLOTS DEBUG ===");
      print("URL: $baseUrl/getslot");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("======================");

      // ---------- 3) Handle response codes ----------
      if (response.statusCode == 200) {
        // Normal success
        try {
          final jsonData = jsonDecode(response.body);
          final List<dynamic> data = jsonData['data'] ?? [];

          if (data.isEmpty) {
            // 200 but empty data – you can decide to use cache or not
            print("⚠️ 200 OK but no slots in data");

            final cached = await OfflineQueueService.getCachedSlots();
            if (cached != null && cached.isNotEmpty) {
              debugPrint('📦 Using cached slots (server returned empty list)');
              return cached.map((e) => SlotModel.fromJson(e)).toList();
            }

            return [];
          }

          // ✅ Cache the fresh data
          await OfflineQueueService.cacheSlots(data);

          return data.map((e) => SlotModel.fromJson(e)).toList();
        } catch (e) {
          print("Error parsing 200 response: $e");

          // ✅ Return cached data on parse error if available
          final cached = await OfflineQueueService.getCachedSlots();
          if (cached != null && cached.isNotEmpty) {
            debugPrint('📦 Using cached slots due to parse error');
            return cached.map((e) => SlotModel.fromJson(e)).toList();
          }

          return [];
        }
      }

      if (response.statusCode == 404) {
        // 🔴 SPECIAL CASE: Backend explicitly says "No slot available"
        try {
          final jsonData = jsonDecode(response.body);
          final message = (jsonData['message'] ?? '').toString().toLowerCase();

          if (message.contains('no slot available')) {
            // ❗ DO NOT USE CACHE here – trust server
            print("⚠️ No slots available from server (404). Ignoring cache.");
            // Optional: clear old cache if you don't want stale shifts:
            // await OfflineQueueService.clearCachedSlots();
            return [];
          }
        } catch (e) {
          print("Error parsing 404 response: $e");
        }

        // 404 for some other reason → treat as error, fall back to cache
        debugPrint(
          '⚠️ 404 from API (not \"No slot available\") - trying cache',
        );
        final cached = await OfflineQueueService.getCachedSlots();
        if (cached != null && cached.isNotEmpty) {
          debugPrint('📦 Using cached slots due to 404');
          return cached.map((e) => SlotModel.fromJson(e)).toList();
        }
        return [];
      }

      // ---------- 4) Other error codes ----------
      throw Exception(
        'Failed to load slots: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      print('❌ Error fetching slots: $e');

      // ✅ Final fallback to cached data
      final cached = await OfflineQueueService.getCachedSlots();
      if (cached != null && cached.isNotEmpty) {
        debugPrint('📦 Using cached slots due to error');
        return cached.map((e) => SlotModel.fromJson(e)).toList();
      }

      // Only throw if no cache is available
      rethrow;
    }
  }

  Future<void> clockIn({
    required String requestID,
    required String inTime,
    String? notes,
    required String signintype,
    String? userLocation,
    bool isRetry = false,
  }) async {
    // Check if online (only if not a retry from sync service)
    if (!isRetry) {
      final isOnline = await OfflineQueueService.isOnline();

      if (!isOnline) {
        // Queue for later
        await OfflineQueueService.queueOperation(OperationType.clockIn, {
          'requestID': requestID,
          'inTime': inTime,
          'notes': notes,
          'signintype': signintype,
          'userLocation': userLocation,
        });
        print('📥 Clock-in queued for offline sync');
        return; // Return successfully - operation queued
      }
    }

    // Online - proceed with API call
    final accessToken = await TokenStorage.getAccessToken();

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

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/clock-in'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Connection timeout - request took too long');
            },
          );

      print("=== CLOCK IN RESPONSE ===");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      print("========================");

      // ✅ FIX: Validate response properly like clock-out does
      if (response.statusCode == 200 || response.statusCode == 404) {
        try {
          final jsonData = jsonDecode(response.body);
          final message = jsonData['message'] ?? '';

          // Check if the response indicates success
          if (message.toLowerCase().contains('success') ||
              message.toLowerCase().contains('logged') ||
              message.toLowerCase().contains('clocked in')) {
            print('✅ Clock-in successful');
            return;
          } else {
            throw Exception('Clock in failed: $message');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Clock in failed: Unable to parse response');
        }
      } else {
        throw Exception(
          'Failed to clock in: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Clock-in API call failed: $e');

      // Queue the operation if API call fails (only if not already a retry)
      if (!isRetry) {
        await OfflineQueueService.queueOperation(OperationType.clockIn, {
          'requestID': requestID,
          'inTime': inTime,
          'notes': notes,
          'signintype': signintype,
          'userLocation': userLocation,
        });
        print('📥 Clock-in queued due to API failure');
        return; // Don't rethrow - operation has been queued successfully
      }

      // If this is a retry, rethrow the error
      rethrow;
    }
  }

  Future<void> clockOut({
    required String requestID,
    required String outTime,
    String? shiftbreak,
    String? notes,
    required String signouttype,
    bool isRetry = false,
  }) async {
    // Check if online (only if not a retry from sync service)
    if (!isRetry) {
      final isOnline = await OfflineQueueService.isOnline();

      if (!isOnline) {
        // Queue for later
        await OfflineQueueService.queueOperation(OperationType.clockOut, {
          'requestID': requestID,
          'outTime': outTime,
          'shiftbreak': shiftbreak,
          'notes': notes,
          'signouttype': signouttype,
        });
        print('📥 Clock-out queued for offline sync');
        return; // Return successfully - operation queued
      }
    }

    // Online - proceed with API call
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

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/clock-out'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Connection timeout - request took too long');
            },
          );

      print("=== CLOCK OUT RESPONSE ===");
      print("Status: ${response.statusCode}");
      print("Body: ${response.body}");
      print("Headers: ${response.headers}");
      print("=========================");

      if (response.statusCode == 200 || response.statusCode == 404) {
        try {
          final jsonData = jsonDecode(response.body);
          final message = jsonData['message'] ?? '';

          if (message.toLowerCase().contains('success') ||
              message.toLowerCase().contains('logged')) {
            print('✅ Clock-out successful');
            return;
          } else {
            throw Exception('Clock out failed: $message');
          }
        } catch (e) {
          if (e is Exception) rethrow;
          throw Exception('Clock out failed: Unable to parse response');
        }
      } else {
        throw Exception(
          'Clock out failed: ${response.statusCode} ${response.body}',
        );
      }
    } catch (e) {
      print('❌ Clock-out API call failed: $e');

      // Queue the operation if API call fails (only if not already a retry)
      if (!isRetry) {
        await OfflineQueueService.queueOperation(OperationType.clockOut, {
          'requestID': requestID,
          'outTime': outTime,
          'shiftbreak': shiftbreak,
          'notes': notes,
          'signouttype': signouttype,
        });
        print('📥 Clock-out queued due to API failure');
        return; // Don't rethrow - operation has been queued successfully
      }

      // If this is a retry, rethrow the error
      rethrow;
    }
  }
}
