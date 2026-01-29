// domain/entity/roster_entity.dart
class RosterEntity {
  final String date;
  final String day;
  final String time;
  final String location;
  final String organizationName;
  final String notes;
  final String designation;
  final String staffName;
  final String breakMinutes;

  RosterEntity({
    required this.date,
    required this.day,
    required this.time,
    required this.location,
    required this.organizationName,
    required this.notes,
    required this.designation,
    required this.staffName,
    required this.breakMinutes,
  });
}
