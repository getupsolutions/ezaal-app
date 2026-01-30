// Replace your AdminAvailabilityModel with this:

import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/entity/admin_availablit_entity.dart';

class AdminAvailabilityModel extends AdminAvailablitEntity {
  const AdminAvailabilityModel({
    required super.id,
    required super.staffid,
    required super.dateof,
    required super.shift,
    super.fromtime,
    super.totime,
    super.notes,
  });

  factory AdminAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AdminAvailabilityModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      staffid: int.tryParse(json['staffid'].toString()) ?? 0,
      dateof: (json['dateof'] ?? '').toString(),
      shift: (json['shift'] ?? 'AM').toString(),
      fromtime: json['fromtime']?.toString(),
      totime: json['totime']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}
