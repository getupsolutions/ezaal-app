abstract class AttendanceRepository {
  Future<void> clockIn({
    required String requestID,
    required String inTime,
    String? notes,
    required String signintype,
    String? userLocation,
  });

  Future<void> clockOut({
    required String requestID,
    required String outTime,
    String? shiftbreak,
    String? notes,
    required String signouttype,
  });
}
