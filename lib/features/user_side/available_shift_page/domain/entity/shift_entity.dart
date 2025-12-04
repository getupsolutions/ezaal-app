class ShiftEntity {
  final int id;
  final String time;
  final String agencyName;
  final String duration;
  final String date;
  final String notes;
  final String location;

  /// UI status: 'un-confirm', 'pending', 'accepted'
  final String status;

  /// Raw backend flags (optional but useful)
  final String adminApprove; // e.g. 'pending', 'accepted', null -> ''

  ShiftEntity({
    required this.id,
    required this.time,
    required this.agencyName,
    required this.duration,
    required this.notes,
    required this.location,
    required this.date,
    this.status = 'un-confirm',
    this.adminApprove = '',
  });
}
