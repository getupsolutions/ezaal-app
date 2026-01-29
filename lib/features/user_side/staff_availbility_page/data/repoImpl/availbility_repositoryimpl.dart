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
  Future<List<AvailabilityEntity>> getAvailability(
    String start,
    String end, {
    int? organiz,
  }) {
    return remote.getAvailability(
      startDate: start,
      endDate: end,
      organiz: organiz,
    );
  }

  @override
  Future<void> saveAvailability(AvailabilityEntity entity) {
    return remote.saveAvailability(
      AvailabilityModel(
        date: entity.date,
        organiz: entity.organiz,
        amFrom: entity.amFrom,
        amTo: entity.amTo,
        pmFrom: entity.pmFrom,
        pmTo: entity.pmTo,
        n8From: entity.n8From,
        n8To: entity.n8To,
        notes: entity.notes, // ✅
      ),
    );
  }

  @override
  Future<void> deleteAvailability(DateTime date, {int? organiz}) {
    return remote.deleteAvailability(dte: _ymd(date), organiz: organiz);
  }

  @override
  Future<void> editAvailability(AvailabilityEntity entity) {
    return remote.editAvailability(
      AvailabilityModel(
        date: entity.date,
        organiz: entity.organiz,
        amFrom: entity.amFrom,
        amTo: entity.amTo,
        pmFrom: entity.pmFrom,
        pmTo: entity.pmTo,
        n8From: entity.n8From,
        n8To: entity.n8To,
        notes: entity.notes,
      ),
    );
  }
}
