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

    return SlotModel(
      id: json['id'].toString(), // This is the organiz_requests ID
      time: timeRange,
      role: json['designation'] ?? '',
      location: json['department']?.toString() ?? '',
      address: address,
      shiftDate: shiftDate,
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
