class AvailabilityEntity {
  final DateTime date;
  final String shift; // 'AM', 'PM', or 'NIGHT'
  final String? fromtime; // HH:mm:ss format
  final String? totime; // HH:mm:ss format
  final String? notes;

  const AvailabilityEntity({
    required this.date,
    required this.shift,
    this.fromtime,
    this.totime,
    this.notes,
  });
}
