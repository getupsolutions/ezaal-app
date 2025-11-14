import 'package:flutter/material.dart';
import '../entity/timesheet_entity.dart';
import '../repository/timesheet_repository.dart';

class GetTimesheetUseCase {
  final TimesheetRepository repository;

  GetTimesheetUseCase(this.repository);

  Future<List<TimesheetEntity>> call({
    String? startDate,
    String? endDate,
    String? organizationId,
  }) async {
    debugPrint('=== USE CASE: Get Timesheet ===');
    debugPrint('Start Date: $startDate');
    debugPrint('End Date: $endDate');
    debugPrint('Organization ID: $organizationId');
    debugPrint('==============================');

    try {
      final timesheets = await repository.getTimesheet(
        startDate: startDate,
        endDate: endDate,
        organizationId: organizationId,
      );
      debugPrint('✅ Repository returned ${timesheets.length} timesheets');
      return timesheets;
    } catch (e) {
      debugPrint('❌ Repository failed: $e');
      rethrow;
    }
  }
}
