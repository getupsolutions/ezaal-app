import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';

class SlotEntity {
  final String id; // This is the requestID from organiz_requests table
  final String time;
  final String role;
  final String location;
  final String address;
  final bool inTimeStatus; // Whether user has clocked in (sigin is not null)
  final bool
  outTimeStatus; // Whether user has clocked out (signout is not null)
  final bool managerStatus;
  final String? userClockinLocation;

  const SlotEntity({
    required this.id,
    required this.time,
    required this.role,
    required this.location,
    required this.address,
    this.inTimeStatus = false,
    this.outTimeStatus = false,
    this.managerStatus = false,
    this.userClockinLocation,
  });

  SlotEntity applyLocalState(LocalSlotState? localState) {
    if (localState == null) return this;

    return SlotEntity(
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
