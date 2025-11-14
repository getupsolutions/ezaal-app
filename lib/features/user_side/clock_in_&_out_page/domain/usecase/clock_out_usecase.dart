import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/attendance_repository.dart';
import 'package:flutter/material.dart';

class ClockOutUseCase {
  final AttendanceRepository repository;
  ClockOutUseCase(this.repository);

  Future<void> call({
    required String requestID,
    required String outTime,
    String? shiftbreak,
    String? notes,
    required String signouttype,
  }) async {
    debugPrint('=== USE CASE: Clock Out ===');
    debugPrint('Request ID: $requestID');
    debugPrint('Out Time: $outTime');
    debugPrint('Shift Break: $shiftbreak');
    debugPrint('Sign Out Type: $signouttype');
    debugPrint('Notes: $notes');
    debugPrint('===========================');

    try {
      await repository.clockOut(
        requestID: requestID,
        outTime: outTime,
        shiftbreak: shiftbreak,
        notes: notes,
        signouttype: signouttype,
      );
      debugPrint('✅ Repository clock out completed');
    } catch (e) {
      debugPrint('❌ Repository clock out failed: $e');
      rethrow;
    }
  }
}
