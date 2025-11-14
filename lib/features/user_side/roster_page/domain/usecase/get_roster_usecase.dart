// domain/usecases/get_roster_usecase.dart
import 'package:ezaal/features/user_side/roster_page/domain/entity/roster_entity.dart';
import 'package:ezaal/features/user_side/roster_page/domain/repository/roster_repository.dart';

class GetRosterUseCase {
  final RosterRepository repository;
  GetRosterUseCase(this.repository);

  Future<List<RosterEntity>> call() async {
    return await repository.getRoster();
  }
}
class GetRosterCalendarUseCase {
  final RosterRepository repository;
  GetRosterCalendarUseCase(this.repository);

  Future<List<RosterEntity>> call() async {
    return await repository.getRosterCalendar();
  }
}
