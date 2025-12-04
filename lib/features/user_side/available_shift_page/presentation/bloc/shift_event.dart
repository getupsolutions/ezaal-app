abstract class ShiftEvent {}

class FetchShifts extends ShiftEvent {}

class ClaimShift extends ShiftEvent {
  final String shiftDate;
  final String shiftTime;
  final int shiftId;
  ClaimShift(this.shiftId, this.shiftDate, this.shiftTime);
}
class UpdateShiftStatus extends ShiftEvent {
  final String date;
  final String timeRange;
  final String status; // 'approved', 'rejected', 'pending'

  UpdateShiftStatus({
    required this.date,
    required this.timeRange,
    required this.status,
  });
}
