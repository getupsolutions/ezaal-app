import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/entity/slot_entity.dart';

class SlotModel extends SlotEntity {
  const SlotModel({
    required super.id,
    required super.time,
    required super.role,
    required super.location,
    required super.address,
    super.inTimeStatus,
    super.outTimeStatus,
    super.managerStatus,
    super.userClockinLocation,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    final fromTime = json['fromtime'] ?? '';
    final toTime = json['totime'] ?? '';
    final timeRange = '$fromTime - $toTime';

    final address = [
      json['street'],
      json['suburb'],
      json['postcode'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    return SlotModel(
      id: json['id'].toString(), // This is the organiz_requests ID
      time: timeRange,
      role: json['designation'] ?? '',
      location: json['department']?.toString() ?? '',
      address: address,
      inTimeStatus: json['inTimeStatus'] ?? false, // From PHP backend
      outTimeStatus: json['outTimeStatus'] ?? false, // From PHP backend
      managerStatus: json['managerStatus'] ?? false,
      userClockinLocation: json['user_clockin_location'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'role': role,
      'location': location,
      'address': address,
      'inTimeStatus': inTimeStatus,
      'outTimeStatus': outTimeStatus,
      'managerStatus': managerStatus,
      'userClockinLocation': userClockinLocation,
    };
  }
}
