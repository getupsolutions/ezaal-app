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

  ClaimedShift({
    required this.date,
    required this.timeRange,
    required this.startDateTime,
    required this.endDateTime,
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

        // ✅ Check if session expired
        if (e.toString().contains('Session expired')) {
          emit(ShiftSessionExpired());
        } else {
          emit(ShiftError(e.toString()));
        }
      }
    });

    on<ClaimShift>((event, emit) async {
      try {
        // Parse the shift time and date
        final conflictingShift = _checkTimeConflict(
          event.shiftDate,
          event.shiftTime,
        );

        if (conflictingShift != null) {
          emit(
            ShiftClaimError(
              'You have already claimed a shift during this time!\n\n'
              'Existing shift: ${conflictingShift.date}\n'
              'Time: ${conflictingShift.timeRange}\n\n',
            ),
          );

          // Re-emit the current state
          final shifts = await getShiftsUseCase();
          emit(ShiftLoaded(shifts));
          return;
        }

        // Claim the shift
        await claimShiftUseCase(event.shiftId);

        // Parse and store the claimed shift details
        final parsedShift = _parseShiftDateTime(
          event.shiftDate,
          event.shiftTime,
        );
        if (parsedShift != null) {
          _claimedShifts.add(parsedShift);
          print(
            '✅ Shift claimed and tracked: ${event.shiftDate} ${event.shiftTime}',
          );
        }

        emit(ShiftClaimSuccess());

        // Re-fetch after claiming
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
  }

  /// Parse shift date and time into a ClaimedShift object
  ClaimedShift? _parseShiftDateTime(String date, String timeRange) {
    try {
      // Extract start and end times from format "22:00 - 06:00" or "14:00 - 22:00"
      final timeParts = timeRange.split(' - ');
      if (timeParts.length != 2) return null;

      final startTimeStr = timeParts[0].trim();
      final endTimeStr = timeParts[1].trim();

      // Parse the date (format: "30 Nov 2025" or "02 Dec 2025")
      DateTime baseDate;
      try {
        baseDate = DateFormat('dd MMM yyyy').parse(date);
      } catch (e) {
        // Try alternative format
        baseDate = DateFormat('dd/MM/yyyy').parse(date);
      }

      // Parse start time
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

      // Parse end time
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

      // If end time is before start time, it means the shift goes into the next day
      if (endDateTime.isBefore(startDateTime)) {
        endDateTime = endDateTime.add(Duration(days: 1));
      }

      return ClaimedShift(
        date: date,
        timeRange: timeRange,
        startDateTime: startDateTime,
        endDateTime: endDateTime,
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
      // Check for time overlap
      // Two shifts overlap if:
      // 1. New shift starts during claimed shift
      // 2. New shift ends during claimed shift
      // 3. New shift completely encompasses claimed shift
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
