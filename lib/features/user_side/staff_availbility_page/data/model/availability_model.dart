import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';

class AvailabilityModel extends AvailabilityEntity {
  const AvailabilityModel({
    required super.date,
    required super.shift,
    super.fromtime,
    super.totime,
    super.notes,
  });

  static DateTime _parseDate(String raw) {
    final p = raw.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      date: _parseDate((json['dateof'] ?? '').toString()),
      shift: json['shift']?.toString() ?? 'AM',
      fromtime: json['fromtime']?.toString(),
      totime: json['totime']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final dateof =
        "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    return {
      "dateof": dateof,
      "shift": shift,
      "fromtime": fromtime,
      "totime": totime,
      "notes": notes,
    };
  }
}
