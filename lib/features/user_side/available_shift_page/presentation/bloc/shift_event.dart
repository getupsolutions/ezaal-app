abstract class ShiftEvent {}

class FetchShifts extends ShiftEvent {}

class ClaimShift extends ShiftEvent {
  final int shiftId;
  ClaimShift(this.shiftId);
}
