// domain/repositories/roster_repository.dart

import 'package:ezaal/features/user_side/roster_page/domain/entity/roster_entity.dart';

abstract class RosterRepository {
  Future<List<RosterEntity>> getRoster();
  Future<List<RosterEntity>> getRosterCalendar();
}
