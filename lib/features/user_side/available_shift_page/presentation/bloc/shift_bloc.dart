import 'package:ezaal/features/user_side/available_shift_page/domain/usecase/claim_shift_usecase.dart';
import 'package:ezaal/features/user_side/available_shift_page/domain/usecase/get_availableshift.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'shift_event.dart';
import 'shift_state.dart';
import 'package:intl/intl.dart';

class ClaimedShift {
  final String date;
  final String timeRange;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String status; // 'pending', 'approved', 'rejected'

  ClaimedShift({
    required this.date,
    required this.timeRange,
    required this.startDateTime,
    required this.endDateTime,
    this.status = 'pending',
  });
}

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final GetAvailableShiftsUseCase getShiftsUseCase;
  final ClaimShiftUseCase claimShiftUseCase;

  final List<ClaimedShift> _claimedShifts = [];

  ShiftBloc(this.getShiftsUseCase, this.claimShiftUseCase)
    : super(ShiftInitial()) {
    on<FetchShifts>((event, emit) async {
      emit(ShiftLoading());
      try {
        final shifts = await getShiftsUseCase();
        if (shifts.isEmpty) {
          emit(ShiftLoaded([]));
        } else {
          emit(ShiftLoaded(shifts));
        }
      } catch (e) {
        print('Error fetching shifts: $e');

        if (e.toString().contains('Session expired')) {
          emit(ShiftSessionExpired());
        } else {
          emit(ShiftError(e.toString()));
        }
      }
    });

    on<ClaimShift>((event, emit) async {
      try {
        // Check for time conflicts
        final conflictingShift = _checkTimeConflict(
          event.shiftDate,
          event.shiftTime,
        );

        if (conflictingShift != null) {
          emit(
            ShiftClaimError(
              'You have already claimed a shift during this time!\n\n'
              'Existing shift: ${conflictingShift.date}\n'
              'Time: ${conflictingShift.timeRange}\n'
              'Status: ${conflictingShift.status == 'pending' ? 'Pending Approval' : 'Approved'}\n',
            ),
          );

          // Re-emit the current state
          final shifts = await getShiftsUseCase();
          emit(ShiftLoaded(shifts));
          return;
        }

        // Claim the shift - this sets status to 'pending' in backend
        await claimShiftUseCase(event.shiftId);

        // Track the shift as pending
        final parsedShift = _parseShiftDateTime(
          event.shiftDate,
          event.shiftTime,
          status: 'pending',
        );
        if (parsedShift != null) {
          _claimedShifts.add(parsedShift);
          print(
            '✅ Shift claimed (pending approval): ${event.shiftDate} ${event.shiftTime}',
          );
        }

        // Show pending approval message
        emit(
          ShiftClaimPending(
            message:
                'Your shift claim has been sent to admin for approval. You will be notified once approved.',
          ),
        );

        // Re-fetch shifts to update the list
        final shifts = await getShiftsUseCase();
        emit(ShiftLoaded(shifts));
      } catch (e) {
        print('Error claiming shift: $e');

        if (e.toString().contains('Session expired')) {
          emit(ShiftSessionExpired());
        } else {
          emit(ShiftError(e.toString()));
        }
      }
    });

    // New event to update shift status when admin approves
    on<UpdateShiftStatus>((event, emit) async {
      final shiftIndex = _claimedShifts.indexWhere(
        (shift) =>
            shift.date == event.date && shift.timeRange == event.timeRange,
      );

      if (shiftIndex != -1) {
        final oldShift = _claimedShifts[shiftIndex];
        _claimedShifts[shiftIndex] = ClaimedShift(
          date: oldShift.date,
          timeRange: oldShift.timeRange,
          startDateTime: oldShift.startDateTime,
          endDateTime: oldShift.endDateTime,
          status: event.status,
        );

        if (event.status == 'approved') {
          emit(
            ShiftClaimSuccess(
              message: 'Your shift has been approved by admin!',
            ),
          );
        }

        // Re-fetch shifts
        final shifts = await getShiftsUseCase();
        emit(ShiftLoaded(shifts));
      }
    });
  }

  /// Parse shift date and time into a ClaimedShift object
  ClaimedShift? _parseShiftDateTime(
    String date,
    String timeRange, {
    String status = 'pending',
  }) {
    try {
      final timeParts = timeRange.split(' - ');
      if (timeParts.length != 2) return null;

      final startTimeStr = timeParts[0].trim();
      final endTimeStr = timeParts[1].trim();

      DateTime baseDate;
      try {
        baseDate = DateFormat('dd MMM yyyy').parse(date);
      } catch (e) {
        baseDate = DateFormat('dd/MM/yyyy').parse(date);
      }

      final startTimeParts = startTimeStr.split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);

      DateTime startDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        startHour,
        startMinute,
      );

      final endTimeParts = endTimeStr.split(':');
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);

      DateTime endDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        endHour,
        endMinute,
      );

      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(Duration(days: 1));
      }

      return ClaimedShift(
        date: date,
        timeRange: timeRange,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
        status: status,
      );
    } catch (e) {
      print('Error parsing shift date/time: $e');
      return null;
    }
  }

  /// Check if the new shift conflicts with any claimed shifts
  ClaimedShift? _checkTimeConflict(String date, String timeRange) {
    final newShift = _parseShiftDateTime(date, timeRange);
    if (newShift == null) return null;

    for (final claimedShift in _claimedShifts) {
      // Only check conflicts with pending or approved shifts
      if (claimedShift.status == 'rejected') continue;

      final hasOverlap =
          (newShift.startDateTime.isBefore(claimedShift.endDateTime) &&
              newShift.endDateTime.isAfter(claimedShift.startDateTime));

      if (hasOverlap) {
        return claimedShift;
      }
    }

    return null;
  }

  /// Clear claimed shifts (e.g., on logout)
  void clearClaimedShifts() {
    _claimedShifts.clear();
    print('🧹 Cleared all claimed shifts');
  }
}
