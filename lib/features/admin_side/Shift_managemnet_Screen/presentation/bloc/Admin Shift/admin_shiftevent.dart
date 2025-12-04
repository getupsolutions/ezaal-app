import 'package:equatable/equatable.dart';

abstract class AdminShiftEvent extends Equatable {
  const AdminShiftEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminShiftsForWeek extends AdminShiftEvent {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int? organizationId;

  const LoadAdminShiftsForWeek({
    required this.weekStart,
    required this.weekEnd,
    this.organizationId,
  });

  @override
  List<Object?> get props => [weekStart, weekEnd, organizationId];
}

class RefreshAdminShifts extends AdminShiftEvent {
  const RefreshAdminShifts();
}

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
}
