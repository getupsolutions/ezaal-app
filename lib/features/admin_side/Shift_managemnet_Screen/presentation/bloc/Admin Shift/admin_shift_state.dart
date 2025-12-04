import 'package:equatable/equatable.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/shift_item.dart';

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
