import 'package:ezaal/features/user_side/timesheet_page/domain/entity/timesheet_entity.dart';

abstract class TimesheetState {}

class TimesheetInitial extends TimesheetState {}

class TimesheetLoading extends TimesheetState {}

class TimesheetLoaded extends TimesheetState {
  final List<TimesheetEntity> timesheets;
  final String? startDate;
  final String? endDate;

  TimesheetLoaded(this.timesheets, {this.startDate, this.endDate});

  // Helper to check if filter is active
  bool get hasActiveFilter => startDate != null && endDate != null;
}

class TimesheetError extends TimesheetState {
  final String message;

  TimesheetError(this.message);
}
