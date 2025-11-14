import 'package:ezaal/features/user_side/clock_in_&_out_page/data/data_source/attendance_remote_data_source.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/entity/slot_entity.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/slot_repository.dart';

class SlotRepositoryImpl implements SlotRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  SlotRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<SlotEntity>> getSlots() {
    return remoteDataSource.getSlots();
  }
}
