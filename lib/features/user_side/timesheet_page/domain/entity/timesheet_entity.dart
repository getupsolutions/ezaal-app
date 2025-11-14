class TimesheetEntity {
  final String id;
  final String date;
  final String userName;
  final String fromTime;
  final String toTime;
  final String organizationName;
  final String address;
  final String clockInTime;
  final String clockOutTime;
  final String totalHours;
  final String breakTime;
  final String notes;
  final String managerName;
  final String managerDesignation;
  final bool hasManagerSignature;
  final String? userClockinLocation;

  const TimesheetEntity({
    required this.id,
    required this.date,
    required this.userName,
    required this.fromTime,
    required this.toTime,
    required this.organizationName,
    required this.address,
    required this.clockInTime,
    required this.clockOutTime,
    required this.totalHours,
    required this.breakTime,
    required this.notes,
    required this.managerName,
    required this.managerDesignation,
    required this.hasManagerSignature,
    this.userClockinLocation
  });
}
