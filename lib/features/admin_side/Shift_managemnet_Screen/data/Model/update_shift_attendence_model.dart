// domain/usecase/update_shift_attendance_usecase.dart

class UpdateShiftAttendanceParams {
  final int shiftId;
  final DateTime? signIn;
  final String? signInType;
  final String? signInReason;
  final DateTime? signOut;
  final String? signOutType;
  final String? signOutReason;
  final int? breakMinutes;
  final String? managerName;
  final String? managerDesignation;

  UpdateShiftAttendanceParams({
    required this.shiftId,
    this.signIn,
    this.signInType,
    this.signInReason,
    this.signOut,
    this.signOutType,
    this.signOutReason,
    this.breakMinutes,
    this.managerName,
    this.managerDesignation,
  });
}


