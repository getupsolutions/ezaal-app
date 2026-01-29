import 'package:equatable/equatable.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_master_model.dart';
import 'package:flutter/material.dart';

abstract class AdminShiftState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AdminShiftInitial extends AdminShiftState {}

class AdminShiftLoading extends AdminShiftState {}

/// Base state that carries shift list and week window
class AdminShiftLoaded extends AdminShiftState {
  final List<ShiftItem> shifts;
  final DateTime weekStart;
  final DateTime weekEnd;

  AdminShiftLoaded({
    required this.shifts,
    required this.weekStart,
    required this.weekEnd,
  });

  @override
  List<Object?> get props => [shifts, weekStart, weekEnd];
}

/// While approving – we still keep and show the existing list
class AdminShiftApproving extends AdminShiftLoaded {
  AdminShiftApproving({
    required List<ShiftItem> shifts,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) : super(shifts: shifts, weekStart: weekStart, weekEnd: weekEnd);
}

/// After success – also extends AdminShiftLoaded, so UI keeps working
class AdminShiftApprovedSuccessfully extends AdminShiftLoaded {
  AdminShiftApprovedSuccessfully({
    required List<ShiftItem> shifts,
    required DateTime weekStart,
    required DateTime weekEnd,
  }) : super(shifts: shifts, weekStart: weekStart, weekEnd: weekEnd);
}

class AdminShiftError extends AdminShiftState {
  final String message;

  AdminShiftError(this.message);

  @override
  List<Object?> get props => [message];
}

class AddEditShiftInitial extends AdminShiftState {}

class AddEditShiftSubmitting extends AdminShiftState {}

class AddEditShiftSuccess extends AdminShiftState {
  final String message;
  AddEditShiftSuccess({required this.message});
}

class AddEditShiftFailure extends AdminShiftState {
  final String message;
  AddEditShiftFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ShiftMastersLoading extends AdminShiftState {}

class ShiftMastersLoaded extends AdminShiftState {
  final ShiftMastersDto masters;

  ShiftMastersLoaded(this.masters);

  @override
  List<Object?> get props => [masters];
}

class ShiftMastersError extends AdminShiftState {
  final String message;

  ShiftMastersError(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminShiftActionSuccess extends AdminShiftLoaded {
  final String message;
  final Color snackColor;

  AdminShiftActionSuccess({
    required this.message,
    required List<ShiftItem> shifts,
    required DateTime weekStart,
    required DateTime weekEnd,
    this.snackColor = Colors.green,
  }) : super(shifts: shifts, weekStart: weekStart, weekEnd: weekEnd);
  @override
  List<Object?> get props => [message, snackColor, shifts, weekStart, weekEnd];
}

class UpdateShiftAttendanceSubmitting extends AdminShiftState {}

class UpdateShiftAttendanceSuccess extends AdminShiftState {
  final String message;

  UpdateShiftAttendanceSuccess({this.message = 'Shift attendance updated'});
}

class UpdateShiftAttendanceFailure extends AdminShiftState {
  final String error;

  UpdateShiftAttendanceFailure(this.error);
}

class OrgMailSending extends AdminShiftState {}

class OrgMailSentSuccess extends AdminShiftState {
  final String message;
  OrgMailSentSuccess(this.message);
}

class OrgMailSentFailure extends AdminShiftState {
  final String error;
  OrgMailSentFailure(this.error);
}

class StaffConfirmedMailSending extends AdminShiftState {}

class StaffConfirmedMailSentSuccess extends AdminShiftState {
  final String message;
  final int sentCount;
  final int failedCount;

  StaffConfirmedMailSentSuccess({
    required this.message,
    required this.sentCount,
    required this.failedCount,
  });

  @override
  List<Object?> get props => [message, sentCount, failedCount];
}

class StaffConfirmedMailSentFailure extends AdminShiftState {
  final String error;

  StaffConfirmedMailSentFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class StaffAvailableShiftMailSending extends AdminShiftState {}

class StaffAvailableShiftMailSentSuccess extends AdminShiftState {
  final String message;
  final int sentCount;
  final int failedCount;
  final int totalEligible;

  StaffAvailableShiftMailSentSuccess({
    required this.message,
    required this.sentCount,
    required this.failedCount,
    required this.totalEligible,
  });

  @override
  List<Object?> get props => [message, sentCount, failedCount, totalEligible];
}

class StaffAvailableShiftMailSentFailure extends AdminShiftState {
  final String error;

  StaffAvailableShiftMailSentFailure(this.error);

  @override
  List<Object?> get props => [error];
}
