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
    super.status,
    super.adminApprove,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    final fromTime = json['fromtime'] ?? '';
    final toTime = json['totime'] ?? '';
    final formattedTime = '$fromTime - $toTime';

    final location = [
      json['street'] ?? '',
      json['suburb'] ?? '',
      json['state'] ?? '',
    ].where((part) => part.isNotEmpty).join(', ');

    final rawDate = json['date']?.toString() ?? '';

    // String formattedDates = '';
    // if (json['date'] != null && json['date'].toString().isNotEmpty) {
    //   try {
    //     final dateTime = DateTime.parse(json['date']);
    //     formattedDates = DateFormat('dd MMM yyyy').format(dateTime);
    //   } catch (e) {
    //     formattedDates = json['date'].toString();
    //   }
    // }

    final rawStatus = (json['status'] ?? 'un-confirm').toString();
    final adminApprove = (json['adminaprrove'] ?? '').toString();

    String uiStatus;
    if (adminApprove == 'pending' || rawStatus == 'pending') {
      uiStatus = 'pending';
    } else if (rawStatus == 'confirmed' && adminApprove == 'accepted') {
      uiStatus = 'accepted';
    } else {
      uiStatus = 'un-confirm';
    }

    return ShiftModel(
      id: int.parse(json['id'].toString()),
      date: rawDate,
      time: formattedTime,
      agencyName: json['organization_name'] ?? 'Unknown',
      duration: json['break'] != null ? '${json['break']} mins break' : '',
      notes: json['notes'] ?? '',
      location: location,
      status: uiStatus,
      adminApprove: adminApprove,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'duration': duration,
      'organization_name': agencyName,
      'notes': notes,
      'location': location,
      'status': status,
      'adminaprrove': adminApprove,
    };
  }
}
