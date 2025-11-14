part of 'attendance_bloc.dart';

abstract class AttendanceState {}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class ClockInSuccess extends AttendanceState {}

class ClockOutSuccess extends AttendanceState {}

class AttendanceFailure extends AttendanceState {
  final String message;
  AttendanceFailure(this.message);
}
