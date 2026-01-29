import 'package:equatable/equatable.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/data/Model/update_shift_attendence_model.dart';

abstract class AdminShiftEvent extends Equatable {
  const AdminShiftEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminShiftsForWeek extends AdminShiftEvent {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int? organizationId;
  final int? staffId;
  final String? status;
  final int? staffTypeId; // local/UI only for now
  final int? departmentId; // local/UI only for now

  LoadAdminShiftsForWeek({
    required this.weekStart,
    required this.weekEnd,
    this.organizationId,
    this.staffId,
    this.status,
    this.staffTypeId,
    this.departmentId,
  });

  @override
  List<Object?> get props => [
    weekStart,
    weekEnd,
    organizationId,
    staffId,
    status,
    staffTypeId,
    departmentId,
  ];
}

class RefreshAdminShifts extends AdminShiftEvent {}

class ApprovePendingShiftClaimsEvent extends AdminShiftEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? organizationId;
  final int? staffId;

  ApprovePendingShiftClaimsEvent({
    this.startDate,
    this.endDate,
    this.organizationId,
    this.staffId,
  });

  @override
  List<Object?> get props => [startDate, endDate, organizationId, staffId];
}

class SubmitShiftEvent extends AdminShiftEvent {
  final int? id;
  final int organizationId;
  final int staffTypeId;
  final DateTime date;
  final String fromTime;
  final String toTime;
  final String notes;
  final int breakMinutes;
  final int? staffId;
  final int? departmentId; // ✅ changed to int? id
  final int copies;

  SubmitShiftEvent({
    this.id,
    required this.organizationId,
    required this.staffTypeId,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.notes,
    required this.breakMinutes,
    this.staffId,
    this.departmentId,
    this.copies = 1,
  });

  @override
  List<Object?> get props => [
    id,
    organizationId,
    staffTypeId,
    date,
    fromTime,
    toTime,
    notes,
    breakMinutes,
    staffId,
    departmentId,
    copies,
  ];
}

class LoadShiftMastersEvent extends AdminShiftEvent {
  const LoadShiftMastersEvent();

  @override
  List<Object?> get props => [];
}

class CancelAdminShiftEvent extends AdminShiftEvent {
  final int shiftId;
  const CancelAdminShiftEvent({required this.shiftId});
}

class CancelAdminShiftStaffEvent extends AdminShiftEvent {
  final int shiftId;
  const CancelAdminShiftStaffEvent({required this.shiftId});
}

class UpdateShiftAttendanceEvent extends AdminShiftEvent {
  final UpdateShiftAttendanceParams params;

  UpdateShiftAttendanceEvent(this.params);
}

class ToggleShiftApprovalEvent extends AdminShiftEvent {
  final int shiftId;
  final bool approve; // true = approve, false = unapprove

  const ToggleShiftApprovalEvent({
    required this.shiftId,
    required this.approve,
  });

  @override
  List<Object?> get props => [shiftId, approve];
}

class SendOrganizationRosterMailEvent extends AdminShiftEvent {
  final DateTime startDate;
  final DateTime endDate;
  final int organizationId;
  final bool includeCancelled;

  const SendOrganizationRosterMailEvent({
    required this.startDate,
    required this.endDate,
    required this.organizationId,
    this.includeCancelled = false,
  });

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    organizationId,
    includeCancelled,
  ];
}

class SendStaffConfirmedMailEvent extends AdminShiftEvent {
  final List<int> shiftIds;

  const SendStaffConfirmedMailEvent({required this.shiftIds});

  @override
  List<Object?> get props => [shiftIds];
}

class SendStaffAvailableShiftMailEvent extends AdminShiftEvent {
  final List<int> shiftIds;

  const SendStaffAvailableShiftMailEvent({required this.shiftIds});

  @override
  List<Object?> get props => [shiftIds];
}
