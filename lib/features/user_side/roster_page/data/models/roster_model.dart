// data/models/roster_model.dart
import 'package:ezaal/features/user_side/roster_page/domain/entity/roster_entity.dart';

class RosterModel extends RosterEntity {
  RosterModel({
    required super.date,
    required super.day,
    required super.time,

    required super.location,
    required super.organizationName,
    required super.notes,
    required super.designation,
    required super.staffName,
    required super.breakMinutes,
  });

  factory RosterModel.fromJson(Map<String, dynamic> json) {
    // Parse date - ensure it's in YYYY-MM-DD format
    final date = json['date'] ?? '';

    // Parse time
    final fromTime = json['fromtime'] ?? '';
    final toTime = json['totime'] ?? '';
    final time = '$fromTime - $toTime';

    // Parse location
    final street = json['street'] ?? '';
    final suburb = json['suburb'] ?? '';
    final postcode = json['postcode'] ?? '';
    final state = json['state'] ?? '';
    final location = '$street, $suburb, $postcode, $state'.trim();

    // Parse day of week
    final dateTime = DateTime.tryParse(date);
    final day = dateTime != null ? _getDayName(dateTime.weekday) : '';

    final staffName = (json['staffreqname'] ?? '').toString();
    final breakMinutes = (json['break'] ?? '').toString();

    return RosterModel(
      date: date,
      day: day,
      time: time,
      location: location,
      organizationName: json['organization_name'] ?? 'Unknown',
      notes: json['notes'] ?? '',
      designation: json['designation'] ?? '',
      staffName: staffName.isEmpty ? '-' : staffName,
      breakMinutes: breakMinutes.isEmpty ? '0' : breakMinutes,
    );
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }
}
