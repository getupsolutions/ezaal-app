class ShiftItem {
  // Basic info
  final int id;
  final String organizationName;
  final String location; // street + suburb + postcode
  final String date; // 'yyyy-MM-dd'
  final String time; // 'HH:mm - HH:mm'
  final String staffName; // may be empty if not assigned
  final String status; // 'un-confirm', 'confirmed', etc.
  final String notes;
  final String breakMinutes; // from `break` column, e.g. "30"

  // Flags to control icons in UI
  final bool hasEdit;
  final bool hasCancel;
  final bool hasAdd;
  final bool hasView;
  final bool hasDocument;

  // Clock in/out + manager + misc
  final String? signIn; // sigin (datetime string)
  final String? signInType; // signintype (ontime / late / etc.)
  final String? signInReason; // signinreason
  final String? signOut; // signout (datetime string)
  final String? signOutType; // signouttype
  final String? signOutReason; // signoutreason
  final String? managerName; // mangername
  final String? managerDesignation; // managerdesig
  final String? managerSignature; // managsig (file name/path)
  final String? departmentName; // department_name or department id toString
  final String? staffRequestDate; // stffreqdte
  final String? staffRequestName; // staffreqname

  ShiftItem({
    required this.id,
    required this.organizationName,
    required this.location,
    required this.date,
    required this.time,
    required this.staffName,
    required this.status,
    this.notes = '',
    this.breakMinutes = '0',
    this.hasEdit = true,
    this.hasCancel = true,
    this.hasAdd = false,
    this.hasView = true,
    this.hasDocument = false,
    this.signIn,
    this.signInType,
    this.signInReason,
    this.signOut,
    this.signOutType,
    this.signOutReason,
    this.managerName,
    this.managerDesignation,
    this.managerSignature,
    this.departmentName,
    this.staffRequestDate,
    this.staffRequestName,
  });

  /// Completed shift = has both clock-in and clock-out
  bool get hasClockInOut =>
      (signIn != null && signIn!.isNotEmpty) &&
      (signOut != null && signOut!.isNotEmpty);

  factory ShiftItem.fromJson(Map<String, dynamic> json) {
    // Location
    final locationFull =
        (json['location_full'] as String?) ??
        '${json['street'] ?? ''}, ${json['suburb'] ?? ''} ${json['postcode'] ?? ''}';

    // Time range
    final timeRange =
        (json['time_range'] as String?) ??
        '${json['fromtime'] ?? ''} - ${json['totime'] ?? ''}';

    final status = (json['status'] as String?) ?? '';

    // Clock fields (needed before computing flags)
    final signInVal = json['sigin']?.toString();
    final signOutVal = json['signout']?.toString();
    final bool isCompleted =
        signInVal != null &&
        signInVal.isNotEmpty &&
        signOutVal != null &&
        signOutVal.isNotEmpty;

    // Default flag logic:
    // - If completed (has clockin & clockout) → view only
    // - Else: keep previous behaviour (no edit/cancel when status == confirmed)
    final bool allowEditCancel = !isCompleted && status != 'confirmed';

    return ShiftItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      organizationName: json['organization_name'] ?? '',
      location: locationFull.trim(),
      date: json['date'] ?? '',
      time: timeRange.trim(),
      staffName: json['staffreqname'] ?? json['staff_name'] ?? '',
      status: status,
      notes: json['notes'] ?? '',
      breakMinutes: json['break']?.toString() ?? '0',

      // flags
      hasEdit: allowEditCancel,
      hasCancel: allowEditCancel,
      hasAdd: false,
      hasView: true,
      hasDocument: false,

      // clock & manager & misc
      signIn: signInVal,
      signInType: json['signintype'],
      signInReason: json['signinreason'],
      signOut: signOutVal,
      signOutType: json['signouttype'],
      signOutReason: json['signoutreason'],
      managerName: json['mangername'],
      managerDesignation: json['managerdesig'],
      managerSignature: json['managsig'],
      departmentName: json['department_name'] ?? json['department']?.toString(),
      staffRequestDate: json['stffreqdte'],
      staffRequestName: json['staffreqname'],
    );
  }
}
