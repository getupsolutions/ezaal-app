// features/admin_side/Shift_managemnet_Screen/domain/usecase/save_admin_shift_params.dart
class SaveAdminShiftParams {
  final int? id; // null => create; non-null => update
  final int organizationId;
  final int staffTypeId;
  final DateTime date;
  final String fromTime; // 'HH:mm'
  final String toTime; // 'HH:mm'
  final String notes;
  final int breakMinutes;
  final int? staffId;
  final int? departmentId;

  SaveAdminShiftParams({
    this.id,
    required this.organizationId,
    required this.staffTypeId,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.notes,
    required this.breakMinutes,
    this.staffId,
    this.departmentId,
  });

  Map<String, dynamic> toJson() {
    String two(int v) => v.toString().padLeft(2, '0');

    final dateStr =
        '${date.year.toString().padLeft(4, '0')}-${two(date.month)}-${two(date.day)}';

    String normalizeTime(String t) {
      // expect "HH:mm" and convert to "HH:mm:00"
      if (t.length == 5) return '$t:00';
      return t; // assume already correct
    }

    return {
      if (id != null) 'id': id,
      'orgid': organizationId,
      'stafftype': staffTypeId,
      'date': dateStr,
      'fromtime': normalizeTime(fromTime),
      'totime': normalizeTime(toTime),
      'notes': notes,
      'break': breakMinutes,
      if (staffId != null) 'staffid': staffId,
      if (departmentId != null) 'department': departmentId,
    };
  }
}
