import 'package:ezaal/features/user_side/staff_availbility_page/data/dataSource/availbility_datasource.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/data/model/availability_model.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/repo/availability_repository.dart';

class AvailabilityRepositoryImpl implements AvailabilityRepository {
  final AvailabilityRemoteDataSource remote;

  AvailabilityRepositoryImpl(this.remote);

  String _ymd(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-"
      "${d.month.toString().padLeft(2, '0')}-"
      "${d.day.toString().padLeft(2, '0')}";

  @override
  Future<List<AvailabilityEntity>> getAvailability(String start, String end) {
    return remote.getAvailability(startDate: start, endDate: end);
  }

  @override
  Future<void> saveAvailability(AvailabilityEntity entity) {
    return remote.saveAvailability(
      AvailabilityModel(
        date: entity.date,
        shift: entity.shift,
        fromtime: entity.fromtime,
        totime: entity.totime,
        notes: entity.notes,
      ),
    );
  }

  @override
  Future<void> deleteAvailability(DateTime date, String shift) {
    return remote.deleteAvailability(dateof: _ymd(date), shift: shift);
  }

  @override
  Future<void> editAvailability(AvailabilityEntity entity) {
    return remote.editAvailability(
      AvailabilityModel(
        date: entity.date,
        shift: entity.shift,
        fromtime: entity.fromtime,
        totime: entity.totime,
        notes: entity.notes,
      ),
    );
  }
}
