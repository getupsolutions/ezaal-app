import 'package:ezaal/features/user_side/timesheet_page/domain/entity/timesheet_entity.dart';

abstract class TimesheetRepository {
  Future<List<TimesheetEntity>> getTimesheet({
    String? startDate,
    String? endDate,
    String? organizationId,
  });
}
