import 'package:ezaal/features/user_side/timesheet_page/data/remoteDatasource/timesheet_remotedatasource.dart';
import 'package:ezaal/features/user_side/timesheet_page/domain/entity/timesheet_entity.dart';
import 'package:ezaal/features/user_side/timesheet_page/domain/repository/timesheet_repository.dart';

class TimesheetRepositoryImpl implements TimesheetRepository {
  final TimesheetRemoteDataSource remoteDataSource;

  TimesheetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<TimesheetEntity>> getTimesheet({
    String? startDate,
    String? endDate,
    String? organizationId,
  }) async {
    print("=== REPOSITORY: Get Timesheet ===");
    print("Requested - Start: $startDate, End: $endDate");

    // Fetch all timesheets from API (since backend doesn't filter properly)
    final timesheets = await remoteDataSource.getTimesheet(
      startDate: startDate,
      endDate: endDate,
      organizationId: organizationId,
    );

    print("✅ Repository received ${timesheets.length} timesheets from API");

    // Client-side filtering if dates are provided
    if (startDate != null &&
        endDate != null &&
        startDate.isNotEmpty &&
        endDate.isNotEmpty) {
      try {
        final start = DateTime.parse(startDate);
        final end = DateTime.parse(endDate);

        print("🔍 Applying client-side filter...");
        print("   Start: $start");
        print("   End: $end");

        final filtered =
            timesheets.where((timesheet) {
              try {
                final timesheetDate = DateTime.parse(timesheet.date);

                // Check if date is within range (inclusive)
                final isInRange =
                    (timesheetDate.isAtSameMomentAs(start) ||
                        timesheetDate.isAfter(start)) &&
                    (timesheetDate.isAtSameMomentAs(end) ||
                        timesheetDate.isBefore(
                          end.add(const Duration(days: 1)),
                        ));

                if (isInRange) {
                  print("   ✓ Including: ${timesheet.date}");
                }

                return isInRange;
              } catch (e) {
                print("   ⚠️ Error parsing date: ${timesheet.date}");
                return false;
              }
            }).toList();

        print("✅ Client-side filter result: ${filtered.length} records");
        print(
          "   Original: ${timesheets.length}, Filtered: ${filtered.length}",
        );

        return filtered;
      } catch (e) {
        print("❌ Error during client-side filtering: $e");
        print("   Returning unfiltered results");
        return timesheets;
      }
    }

    print(
      "📋 No date filter applied, returning all ${timesheets.length} records",
    );
    return timesheets;
  }
}
