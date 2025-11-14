import 'package:ezaal/features/user_side/available_shift_page/domain/entity/shift_entity.dart';

class ShiftModel extends ShiftEntity {
  ShiftModel({
    required super.id,
    required super.time,
    required super.agencyName,
    required super.duration,
    required super.notes,
    required super.location,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    // Combine fromtime and totime into one display string
    final fromTime = json['fromtime'] ?? '';
    final toTime = json['totime'] ?? '';
    final formattedTime = '$fromTime - $toTime';

    // Build readable location
    final location = [
      json['street'] ?? '',
      json['suburb'] ?? '',
      json['state'] ?? '',
    ].where((part) => part.isNotEmpty).join(', ');

    print(
      'Mapped shift: id=${json['id']}, org=${json['organization_name']}, time=$formattedTime',
    );


    return ShiftModel(
      id: int.parse(json['id'].toString()),
      time: formattedTime,
      agencyName: json['organization_name'] ?? 'Unknown',
      duration: json['break'] != null ? '${json['break']} mins break' : '',
      notes: json['notes'] ?? '',
      location: location,
    );
  }
}
