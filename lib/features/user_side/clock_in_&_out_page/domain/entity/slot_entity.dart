class SlotEntity {
  final String id; // This is the requestID from organiz_requests table
  final String time;
  final String role;
  final String location;
  final String address;
  final bool inTimeStatus; // Whether user has clocked in (sigin is not null)
  final bool
  outTimeStatus; // Whether user has clocked out (signout is not null)
  final bool managerStatus;
  final String? userClockinLocation;

  const SlotEntity({
    required this.id,
    required this.time,
    required this.role,
    required this.location,
    required this.address,
    this.inTimeStatus = false,
    this.outTimeStatus = false,
    this.managerStatus = false,
    this.userClockinLocation,
  });
}
