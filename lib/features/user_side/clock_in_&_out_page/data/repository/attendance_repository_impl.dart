import 'package:ezaal/features/user_side/clock_in_&_out_page/data/data_source/attendance_remote_data_source.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/attendance_repository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> clockIn({
    required String requestID,
    required String inTime,
    String? notes,
    required String signintype,
    String? userLocation,
  }) {
    return remoteDataSource.clockIn(
      requestID: requestID,
      inTime: inTime,
      notes: notes,
      signintype: signintype,
      userLocation: userLocation,
    );
  }

  @override
  Future<void> clockOut({
    required String requestID,
    required String outTime,
    String? shiftbreak,
    String? notes,
    required String signouttype,
  }) {
    return remoteDataSource.clockOut(
      requestID: requestID,
      outTime: outTime,
      shiftbreak: shiftbreak,
      notes: notes,
      signouttype: signouttype,
    );
  }
}
