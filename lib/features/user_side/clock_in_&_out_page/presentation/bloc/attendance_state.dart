abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class ClockInSuccess extends AttendanceState {
  final bool isOfflineQueued;
  ClockInSuccess({this.isOfflineQueued = false});
}

class ClockOutSuccess extends AttendanceState {
  final bool isOfflineQueued;
  ClockOutSuccess({this.isOfflineQueued = false});
}

class AttendanceFailure extends AttendanceState {
  final String message;
  AttendanceFailure(this.message);
}


