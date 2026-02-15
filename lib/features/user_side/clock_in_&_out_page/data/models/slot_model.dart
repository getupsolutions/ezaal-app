import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/entity/slot_entity.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';

class SlotModel extends SlotEntity {
  const SlotModel({
    required super.id,
    required super.time,
    required super.role,
    required super.location,
    required super.address,
    super.shiftDate,
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

    String? shiftDate;
    if (json['shift_date'] != null) {
      shiftDate = json['shift_date'].toString();
    } else if (json['date'] != null) {
      shiftDate = json['date'].toString();
    } else if (json['shift_start_date'] != null) {
      shiftDate = json['shift_start_date'].toString();
    }

    String departmentName = '';

    if (json['department_name'] != null &&
        json['department_name'].toString().isNotEmpty) {
      // If backend returns 'department_name' from JOIN
      departmentName = json['department_name'].toString();
    } else if (json['department'] != null) {
      // Check if it's already a name (string) or ID (number)
      final deptValue = json['department'];
      if (deptValue is String && !_isNumeric(deptValue)) {
        // It's already a name
        departmentName = deptValue;
      } else if (deptValue is int ||
          (deptValue is String && _isNumeric(deptValue))) {
        // It's an ID - this shouldn't happen if backend is properly joined
        // But we'll handle it gracefully
        departmentName = 'Department #$deptValue';
      }
    }
    final orgName = (json['org_name'] ?? '').toString();
    return SlotModel(
      id: json['id'].toString(),
      time: timeRange,
      role: json['designation'] ?? '',
      location: orgName.isNotEmpty ? orgName : 'No Organization', // ✅ FIXED
      address: address,
      shiftDate: shiftDate,
      inTimeStatus: json['inTimeStatus'] ?? false,
      outTimeStatus: json['outTimeStatus'] ?? false,
      managerStatus: json['managerStatus'] ?? false,
      userClockinLocation: json['user_clockin_location'],
    );
  }
  static bool _isNumeric(String? str) {
    if (str == null || str.isEmpty) return false;
    return double.tryParse(str) != null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time,
      'role': role,
      'location': location,
      'address': address,
      'date': shiftDate,
      'inTimeStatus': inTimeStatus,
      'outTimeStatus': outTimeStatus,
      'managerStatus': managerStatus,
      'userClockinLocation': userClockinLocation,
    };
  }

  @override
  SlotModel applyLocalState(LocalSlotState? localState) {
    if (localState == null) return this;

    return SlotModel(
      id: id,
      time: time,
      role: role,
      location: location,
      address: address,
      // Apply local state OR server state
      inTimeStatus: localState.hasLocalClockIn || inTimeStatus,
      outTimeStatus: localState.hasLocalClockOut || outTimeStatus,
      managerStatus: localState.hasLocalManagerInfo || managerStatus,
      userClockinLocation: userClockinLocation,
    );
  }
}
