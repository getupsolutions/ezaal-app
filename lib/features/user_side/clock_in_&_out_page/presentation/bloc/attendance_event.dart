part of 'attendance_bloc.dart';

abstract class AttendanceEvent {}

class ClockInRequested extends AttendanceEvent {
  final String requestID;
  final String inTime; // Current date and time when clocking in
  final String? notes; // Reason for late/early clock in
  final String signintype; // 'early', 'late', or 'ontime'
   final String? userLocation;

  ClockInRequested({
    required this.requestID,
    required this.inTime,
    this.notes,
    required this.signintype,
    this.userLocation
  });
}

class ClockOutRequested extends AttendanceEvent {
  final String requestID;
  final String outTime; // Current date and time when clocking out
  final String? shiftbreak; // Break time in minutes
  final String? notes; // Reason for late/early clock out
  final String signouttype; // 'early', 'late', or 'ontime'

  ClockOutRequested({
    required this.requestID,
    required this.outTime,
    this.shiftbreak,
    this.notes,
    required this.signouttype,
  });
}
