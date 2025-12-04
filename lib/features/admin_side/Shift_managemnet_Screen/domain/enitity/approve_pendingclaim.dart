import 'package:intl/intl.dart';

class ApprovePendingClaimsParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? organizationId;
  final int? staffId;

  ApprovePendingClaimsParams({
    this.startDate,
    this.endDate,
    this.organizationId,
    this.staffId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (startDate != null)
        'start_date': DateFormat('yyyy-MM-dd').format(startDate!),
      if (endDate != null)
        'end_date': DateFormat('yyyy-MM-dd').format(endDate!),
      if (organizationId != null) 'organization_id': organizationId,
      if (staffId != null) 'staff_id': staffId,
    };
  }
}
