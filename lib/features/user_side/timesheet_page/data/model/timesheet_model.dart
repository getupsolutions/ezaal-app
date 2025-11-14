import '../../domain/entity/timesheet_entity.dart';

class TimesheetModel extends TimesheetEntity {
  const TimesheetModel({
    required super.userName,
    required super.id,
    required super.date,
    required super.fromTime,
    required super.toTime,
    required super.organizationName,
    required super.address,
    required super.clockInTime,
    required super.clockOutTime,
    required super.totalHours,
    required super.breakTime,
    required super.notes,
    required super.managerName,
    required super.managerDesignation,
    required super.hasManagerSignature,
  });

  factory TimesheetModel.fromJson(Map<String, dynamic> json) {
    // Build address from components
    final address = [
      json['street'],
      json['suburb'],
      json['postcode'],
      json['state'],
    ].where((e) => e != null && e.toString().isNotEmpty).join(', ');

    // Format times
    final clockIn = json['sigin'] ?? '-';
    final clockOut = json['signout'] ?? '-';

    return TimesheetModel(
      userName: json['staffreqname'] ?? '',
      id: json['id'].toString(),
      date: json['date'] ?? '',
      fromTime: json['fromtime'] ?? '',
      toTime: json['totime'] ?? '',
      organizationName: json['organization_name'] ?? '',
      address: address,
      clockInTime: clockIn != '-' ? _formatDateTime(clockIn) : '-',
      clockOutTime: clockOut != '-' ? _formatDateTime(clockOut) : '-',
      totalHours: json['time_hours'] ?? '00:00',
      breakTime: json['shiftbreak']?.toString() ?? '0',
      notes: json['notes'] ?? '',
      managerName: json['mangername'] ?? '',
      managerDesignation: json['managerdesig'] ?? '',
      hasManagerSignature:
          json['managsig'] != null && json['managsig'].toString().isNotEmpty,
    );
  }

  static String _formatDateTime(String dateTime) {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'fromTime': fromTime,
      'toTime': toTime,
      'organizationName': organizationName,
      'address': address,
      'clockInTime': clockInTime,
      'clockOutTime': clockOutTime,
      'totalHours': totalHours,
      'breakTime': breakTime,
      'notes': notes,
      'managerName': managerName,
      'managerDesignation': managerDesignation,
      'hasManagerSignature': hasManagerSignature,
    };
  }
}
