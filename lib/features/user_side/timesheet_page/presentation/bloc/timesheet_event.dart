abstract class TimesheetEvent {}

class LoadTimesheet extends TimesheetEvent {
  final String? startDate;
  final String? endDate;
  final String? organizationId;

  LoadTimesheet({this.startDate, this.endDate, this.organizationId});
}

class FilterTimesheetByDate extends TimesheetEvent {
  final String startDate;
  final String endDate;

  FilterTimesheetByDate({required this.startDate, required this.endDate});
}

class ClearTimesheetFilter extends TimesheetEvent {}
