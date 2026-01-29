import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';

class AvailabilityModel extends AvailabilityEntity {
  const AvailabilityModel({
    required super.date,
    super.amFrom,
    super.amTo,
    super.pmFrom,
    super.pmTo,
    super.n8From,
    super.n8To,
    super.notes, // ✅
    super.organiz,
  });

  static DateTime _parseDate(String raw) {
    final p = raw.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  factory AvailabilityModel.fromJson(Map<String, dynamic> json) {
    return AvailabilityModel(
      date: _parseDate((json['dte'] ?? '').toString()),
      amFrom: json['amfrom']?.toString(),
      amTo: json['amto']?.toString(),
      pmFrom: json['pmfrom']?.toString(),
      pmTo: json['pmto']?.toString(),
      n8From: json['n8from']?.toString(),
      n8To: json['n8to']?.toString(),
      notes: json['notes']?.toString(), // ✅
      organiz: int.tryParse((json['organiz'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() {
    final dte =
        "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";

    return {
      "dte": dte,
      "organiz": organiz,
      "amfrom": amFrom,
      "amto": amTo,
      "pmfrom": pmFrom,
      "pmto": pmTo,
      "n8from": n8From,
      "n8to": n8To,
      "notes": notes, // ✅
    };
  }
}
