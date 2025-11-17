// ====================
// 1. offline_queue_service.dart
// ====================
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum OperationType { clockIn, clockOut, managerInfo }

class QueuedOperation {
  final String id;
  final OperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;
  final String? signatureBase64; // For manager info signatures

  QueuedOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
    this.signatureBase64,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.toString(),
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
        if (signatureBase64 != null) 'signatureBase64': signatureBase64,
      };

  factory QueuedOperation.fromJson(Map<String, dynamic> json) {
    return QueuedOperation(
      id: json['id'],
      type: OperationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
      signatureBase64: json['signatureBase64'],
    );
  }

  QueuedOperation copyWith({int? retryCount}) {
    return QueuedOperation(
      id: id,
      type: type,
      data: data,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
      signatureBase64: signatureBase64,
    );
  }
}

class OfflineQueueService {
  static const String _queueKey = 'offline_operations_queue';
  static const String _syncStatusKey = 'offline_sync_status';
  static const int maxRetries = 3;

  // Check if device is online
  static Future<bool> isOnline() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  // Add operation to queue
  static Future<void> queueOperation(
    OperationType type,
    Map<String, dynamic> data, {
    Uint8List? signatureBytes,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await getQueue();

    // Convert signature to base64 if provided
    String? signatureBase64;
    if (signatureBytes != null) {
      signatureBase64 = base64Encode(signatureBytes);
    }

    final operation = QueuedOperation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      data: data,
      timestamp: DateTime.now(),
      signatureBase64: signatureBase64,
    );

    queue.add(operation);
    await _saveQueue(queue);

    print('📥 Queued ${type.toString()}: ${operation.id}');
    print('   Request ID: ${data['requestID']}');
    print('   Queue size: ${queue.length}');
  }

  // Get all queued operations
  static Future<List<QueuedOperation>> getQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queueJson = prefs.getString(_queueKey);

      if (queueJson == null) return [];

      final List<dynamic> decoded = jsonDecode(queueJson);
      return decoded.map((e) => QueuedOperation.fromJson(e)).toList();
    } catch (e) {
      print('Error loading queue: $e');
      return [];
    }
  }

  // Save queue to storage
  static Future<void> _saveQueue(List<QueuedOperation> queue) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(queue.map((e) => e.toJson()).toList());
      await prefs.setString(_queueKey, encoded);
    } catch (e) {
      print('Error saving queue: $e');
    }
  }

  // Remove operation from queue
  static Future<void> removeOperation(String operationId) async {
    final queue = await getQueue();
    queue.removeWhere((op) => op.id == operationId);
    await _saveQueue(queue);
    print('✅ Removed operation: $operationId');
  }

  // Update operation retry count
  static Future<void> updateRetryCount(
    String operationId,
    int retryCount,
  ) async {
    final queue = await getQueue();
    final index = queue.indexWhere((op) => op.id == operationId);

    if (index != -1) {
      queue[index] = queue[index].copyWith(retryCount: retryCount);
      await _saveQueue(queue);
    }
  }

  // Clear entire queue
  static Future<void> clearQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_queueKey);
    print('🗑️ Queue cleared');
  }

  // Get queue count
  static Future<int> getQueueCount() async {
    final queue = await getQueue();
    return queue.length;
  }

  // Get sync status
  static Future<bool> isSyncing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_syncStatusKey) ?? false;
  }

  // Set sync status
  static Future<void> setSyncStatus(bool syncing) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_syncStatusKey, syncing);
  }

  // Check if operation for request is already queued
  static Future<bool> isOperationQueued(
    String requestID,
    OperationType type,
  ) async {
    final queue = await getQueue();
    return queue.any(
      (op) => op.type == type && op.data['requestID'] == requestID,
    );
  }

  // Get pending operations for a specific request
  static Future<List<QueuedOperation>> getPendingOperationsForRequest(
    String requestID,
  ) async {
    final queue = await getQueue();
    return queue.where((op) => op.data['requestID'] == requestID).toList();
  }

  // Get operations by type
  static Future<List<QueuedOperation>> getOperationsByType(
    OperationType type,
  ) async {
    final queue = await getQueue();
    return queue.where((op) => op.type == type).toList();
  }
}

// ====================
// 2. offline_sync_service.dart
// ====================


class OfflineSyncService {
  final dynamic attendanceDataSource;
  final dynamic managerInfoDataSource;

  OfflineSyncService({
    required this.attendanceDataSource,
    required this.managerInfoDataSource,
  });

  // Sync all pending operations
  Future<Map<String, dynamic>> syncAllOperations() async {
    debugPrint('=== STARTING OFFLINE SYNC ===');

    final isOnline = await OfflineQueueService.isOnline();
    if (!isOnline) {
      debugPrint('❌ Device is offline, cannot sync');
      return {
        'success': false,
        'message': 'Device is offline',
        'synced': 0,
        'failed': 0,
      };
    }

    final isSyncing = await OfflineQueueService.isSyncing();
    if (isSyncing) {
      debugPrint('⚠️ Sync already in progress');
      return {
        'success': false,
        'message': 'Sync already in progress',
        'synced': 0,
        'failed': 0,
      };
    }

    await OfflineQueueService.setSyncStatus(true);

    final queue = await OfflineQueueService.getQueue();
    debugPrint('📦 Total operations in queue: ${queue.length}');

    int syncedCount = 0;
    int failedCount = 0;
    List<String> failedOperations = [];

    for (final operation in queue) {
      try {
        debugPrint('\n--- Processing Operation ${operation.id} ---');
        debugPrint('Type: ${operation.type}');
        debugPrint('Retry Count: ${operation.retryCount}');

        if (operation.retryCount >= OfflineQueueService.maxRetries) {
          debugPrint('❌ Max retries reached, removing from queue');
          await OfflineQueueService.removeOperation(operation.id);
          failedCount++;
          failedOperations.add(operation.id);
          continue;
        }

        bool success = false;

        switch (operation.type) {
          case OperationType.clockIn:
            success = await _syncClockIn(operation);
            break;
          case OperationType.clockOut:
            success = await _syncClockOut(operation);
            break;
          case OperationType.managerInfo:
            success = await _syncManagerInfo(operation);
            break;
        }

        if (success) {
          await OfflineQueueService.removeOperation(operation.id);
          syncedCount++;
          debugPrint('✅ Operation ${operation.id} synced successfully');
        } else {
          await OfflineQueueService.updateRetryCount(
            operation.id,
            operation.retryCount + 1,
          );
          failedCount++;
          failedOperations.add(operation.id);
          debugPrint('❌ Operation ${operation.id} failed');
        }
      } catch (e) {
        debugPrint('❌ Error processing operation ${operation.id}: $e');
        await OfflineQueueService.updateRetryCount(
          operation.id,
          operation.retryCount + 1,
        );
        failedCount++;
        failedOperations.add(operation.id);
      }
    }

    await OfflineQueueService.setSyncStatus(false);

    debugPrint('\n=== SYNC COMPLETED ===');
    debugPrint('✅ Synced: $syncedCount');
    debugPrint('❌ Failed: $failedCount');
    debugPrint('======================\n');

    return {
      'success': failedCount == 0,
      'message': failedCount == 0
          ? 'All operations synced successfully'
          : '$syncedCount synced, $failedCount failed',
      'synced': syncedCount,
      'failed': failedCount,
      'failedOperations': failedOperations,
    };
  }

  Future<bool> _syncClockIn(QueuedOperation operation) async {
    try {
      debugPrint('Syncing Clock In...');
      await attendanceDataSource.clockIn(
        requestID: operation.data['requestID'],
        inTime: operation.data['inTime'],
        notes: operation.data['notes'],
        signintype: operation.data['signintype'],
        userLocation: operation.data['userLocation'],
      );
      return true;
    } catch (e) {
      debugPrint('Clock In sync error: $e');
      return false;
    }
  }

  Future<bool> _syncClockOut(QueuedOperation operation) async {
    try {
      debugPrint('Syncing Clock Out...');
      await attendanceDataSource.clockOut(
        requestID: operation.data['requestID'],
        outTime: operation.data['outTime'],
        shiftbreak: operation.data['shiftbreak'],
        notes: operation.data['notes'],
        signouttype: operation.data['signouttype'],
      );
      return true;
    } catch (e) {
      debugPrint('Clock Out sync error: $e');
      return false;
    }
  }

  Future<bool> _syncManagerInfo(QueuedOperation operation) async {
    try {
      debugPrint('Syncing Manager Info...');

      if (operation.signatureBase64 == null) {
        debugPrint('❌ No signature data found');
        return false;
      }

      final signatureBytes = base64Decode(operation.signatureBase64!);

      await managerInfoDataSource.submitManagerInfo(
        requestID: operation.data['requestID'],
        managerName: operation.data['managerName'],
        managerDesignation: operation.data['managerDesignation'],
        signatureBytes: signatureBytes,
      );
      return true;
    } catch (e) {
      debugPrint('Manager Info sync error: $e');
      return false;
    }
  }

  // Sync specific operation
  Future<bool> syncOperation(String operationId) async {
    final queue = await OfflineQueueService.getQueue();
    final operation = queue.firstWhere(
      (op) => op.id == operationId,
      orElse: () => throw Exception('Operation not found'),
    );

    bool success = false;
    switch (operation.type) {
      case OperationType.clockIn:
        success = await _syncClockIn(operation);
        break;
      case OperationType.clockOut:
        success = await _syncClockOut(operation);
        break;
      case OperationType.managerInfo:
        success = await _syncManagerInfo(operation);
        break;
    }

    if (success) {
      await OfflineQueueService.removeOperation(operationId);
    }

    return success;
  }
}