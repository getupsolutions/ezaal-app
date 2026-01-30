// Replace your AdminAvailablitEntity with this:

class AdminAvailablitEntity {
  final int id;
  final int staffid; // Changed from userid to match DB
  final String dateof; // Changed from dte to match DB
  final String shift; // Added: 'AM', 'PM', or 'NIGHT'

  final String? fromtime; // Changed from amfrom/pmfrom/n8from
  final String? totime; // Changed from amto/pmto/n8to
  final String? notes;

  const AdminAvailablitEntity({
    required this.id,
    required this.staffid,
    required this.dateof,
    required this.shift,
    this.fromtime,
    this.totime,
    this.notes,
  });

  DateTime get date => DateTime.tryParse(dateof) ?? DateTime(1970, 1, 1);
}
