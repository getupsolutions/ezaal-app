abstract class ShiftEvent {}

class FetchShifts extends ShiftEvent {}

class ClaimShift extends ShiftEvent {
  final String shiftDate;
  final String shiftTime;
  final int shiftId;
  ClaimShift(this.shiftId, this.shiftDate, this.shiftTime);
}
