// data/repositories/roster_repository_impl.dart
import 'package:ezaal/features/user_side/roster_page/data/data_source/roster_remote_data_source.dart';
import 'package:ezaal/features/user_side/roster_page/domain/entity/roster_entity.dart';
import 'package:ezaal/features/user_side/roster_page/domain/repository/roster_repository.dart';

class RosterRepositoryImpl implements RosterRepository {
  final RosterRemoteDataSource remoteDataSource;

  RosterRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<RosterEntity>> getRoster() async {
    return await remoteDataSource.getRoster();
  }

  @override
  Future<List<RosterEntity>> getRosterCalendar() async {
    return await remoteDataSource.getRosterCalendar();
  }
}
