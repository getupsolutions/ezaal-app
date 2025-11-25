import 'package:ezaal/features/user_side/available_shift_page/domain/entity/shift_entity.dart';
import 'package:intl/intl.dart';

class ShiftModel extends ShiftEntity {
  ShiftModel({
    required super.id,
    required super.time,
    required super.agencyName,
    required super.duration,
    required super.notes,
    required super.location,
    required super.date,
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
    String formattedDates = '';
    if (json['date'] != null && json['date'].isNotEmpty) {
      try {
        final dateTime = DateTime.parse(json['date']);
        formattedDates = DateFormat(
          'dd MMM yyyy',
        ).format(dateTime); // e.g., "25 Nov 2025"
        // Or use DateFormat('dd/MM/yyyy') for "25/11/2025"
      } catch (e) {
        formattedDates = json['date']; // Fallback to original if parsing fails
        print('Date parsing error: $e');
      }
    }

    return ShiftModel(
      id: int.parse(json['id'].toString()),
      date: formattedDates,
      time: formattedTime,
      agencyName: json['organization_name'] ?? 'Unknown',
      duration: json['break'] != null ? '${json['break']} mins break' : '',
      notes: json['notes'] ?? '',
      location: location,
    );
  }
}
