// clock_in_usecase.dart
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/attendance_repository.dart';

class ClockInUseCase {
  final AttendanceRepository repository;
  ClockInUseCase(this.repository);

  Future<void> call({
    required String requestID,
    required String inTime,
    String? notes,
    required String signintype,
    String? userLocation,
  }) async {
    return repository.clockIn(
      requestID: requestID,
      inTime: inTime,
      notes: notes,
      signintype: signintype,
      userLocation: userLocation,
    );
  }
}
