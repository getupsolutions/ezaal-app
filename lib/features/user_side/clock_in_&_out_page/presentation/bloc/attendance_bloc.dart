import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/usecase/clock_in_usecase.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/usecase/clock_out_usecase.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_state.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'attendance_event.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final ClockInUseCase clockInUseCase;
  final ClockOutUseCase clockOutUseCase;

  AttendanceBloc({required this.clockInUseCase, required this.clockOutUseCase})
    : super(AttendanceInitial()) {
    on<ClockInRequested>(_onClockInRequested);
    on<ClockOutRequested>(_onClockOutRequested);
  }

  Future<void> _onClockInRequested(
    ClockInRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    debugPrint('=== BLOC: Clock In Requested ===');
    debugPrint('Request ID: ${event.requestID}');

    emit(AttendanceLoading());

    // ✅ Check if device is online BEFORE operation
    final isOnlineBefore = await OfflineQueueService.isOnline();
    debugPrint('Device online before operation: $isOnlineBefore');

    try {
      await clockInUseCase(
        requestID: event.requestID,
        inTime: event.inTime,
        notes: event.notes,
        signintype: event.signintype,
        userLocation: event.userLocation,
      );

      // ✅ After operation, check if it was queued
      final wasQueued = await OfflineQueueService.isOperationQueued(
        event.requestID,
        OperationType.clockIn,
      );

      debugPrint('✅ Clock in completed (queued: $wasQueued)');

      // ✅ ALWAYS emit success, whether online or offline
      emit(ClockInSuccess(isOfflineQueued: wasQueued));
      debugPrint('State emitted: ClockInSuccess (offline: $wasQueued)');
    } catch (e) {
      debugPrint('❌ Clock in error: $e');
      emit(AttendanceFailure(e.toString()));
    }
  }

  Future<void> _onClockOutRequested(
    ClockOutRequested event,
    Emitter<AttendanceState> emit,
  ) async {
    debugPrint('=== BLOC: Clock Out Requested ===');
    debugPrint('Request ID: ${event.requestID}');

    emit(AttendanceLoading());

    final isOnlineBefore = await OfflineQueueService.isOnline();
    debugPrint('Device online before operation: $isOnlineBefore');

    try {
      await clockOutUseCase(
        requestID: event.requestID,
        outTime: event.outTime,
        shiftbreak: event.shiftbreak,
        notes: event.notes,
        signouttype: event.signouttype,
      );

      // ✅ After operation, check if it was queued
      final wasQueued = await OfflineQueueService.isOperationQueued(
        event.requestID,
        OperationType.clockOut,
      );

      debugPrint('✅ Clock out completed (queued: $wasQueued)');

      // ✅ ALWAYS emit success, whether online or offline
      emit(ClockOutSuccess(isOfflineQueued: wasQueued));
      debugPrint('State emitted: ClockOutSuccess (offline: $wasQueued)');
    } catch (e) {
      debugPrint('❌ Clock out error: $e');
      emit(AttendanceFailure(e.toString()));
    }
  }
}
