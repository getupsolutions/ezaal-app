import 'package:ezaal/features/user_side/available_shift_page/data/data_source/shift_remote_datasource.dart';
import 'package:ezaal/features/user_side/available_shift_page/domain/entity/shift_entity.dart';
import '../../domain/repository/shift_repository.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftRemoteDataSource remoteDataSource;

  ShiftRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ShiftEntity>> getAvailableShifts() {
    return remoteDataSource.getAvailableShifts();
  }

  @override
  Future<void> claimShift(int shiftId) {
    return remoteDataSource.claimShift(shiftId);
  }
}
