import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/domain/entity/admin_availablit_entity.dart';


class AdminAvailabilityModel extends AdminAvailablitEntity {
  const AdminAvailabilityModel({
    required super.id,
    required super.userid,
    required super.dte,
    super.organiz,
    super.amfrom,
    super.amto,
    super.pmfrom,
    super.pmto,
    super.n8from,
    super.n8to,
    super.notes,
  });

  factory AdminAvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AdminAvailabilityModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      userid: int.tryParse(json['userid'].toString()) ?? 0,
      dte: (json['dte'] ?? '').toString(),
      organiz:
          json['organiz'] == null
              ? null
              : int.tryParse(json['organiz'].toString()),
      amfrom: json['amfrom']?.toString(),
      amto: json['amto']?.toString(),
      pmfrom: json['pmfrom']?.toString(),
      pmto: json['pmto']?.toString(),
      n8from: json['n8from']?.toString(),
      n8to: json['n8to']?.toString(),
      notes: json['notes']?.toString(),
    );
  }
}
