import 'package:ezaal/features/user_side/staff_availbility_page/domain/entity/availability_entity.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/domain/repo/availability_repository.dart';

class GetAvailabilityUseCase {
  final AvailabilityRepository repo;
  GetAvailabilityUseCase(this.repo);

  Future<List<AvailabilityEntity>> call(String start, String end) {
    return repo.getAvailability(start, end);
  }
}

class SaveAvailabilityUseCase {
  final AvailabilityRepository repo;
  SaveAvailabilityUseCase(this.repo);

  Future<void> call(AvailabilityEntity entity) => repo.saveAvailability(entity);
}

class DeleteAvailabilityUseCase {
  final AvailabilityRepository repo;
  DeleteAvailabilityUseCase(this.repo);

  Future<void> call(DateTime date, String shift) =>
      repo.deleteAvailability(date, shift);
}

class EditAvailabilityUseCase {
  final AvailabilityRepository repo;
  EditAvailabilityUseCase(this.repo);

  Future<void> call(AvailabilityEntity entity) => repo.editAvailability(entity);
}
