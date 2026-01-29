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

  final int? staffId; // from staffid column
  final String? adminApprove;
  final String staffTypeDesignation;

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
  final String? userClockinLocation;

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
    this.staffId,
    this.adminApprove,
    this.staffTypeDesignation = '', // ✅ NEW
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
    this.userClockinLocation,
  });

  /// Completed shift = has both clock-in and clock-out
  bool get hasClockInOut =>
      (signIn != null && signIn!.isNotEmpty) &&
      (signOut != null && signOut!.isNotEmpty);

  String get clockinLocationDisplay {
    if (userClockinLocation == null || userClockinLocation!.isEmpty) {
      return '-';
    }

    // If it's coordinates (lat,lng format)
    if (userClockinLocation!.contains(',')) {
      final parts = userClockinLocation!.split(',');
      if (parts.length == 2) {
        try {
          final lat = double.parse(parts[0].trim());
          final lng = double.parse(parts[1].trim());
          return 'Lat: ${lat.toStringAsFixed(6)}, Lng: ${lng.toStringAsFixed(6)}';
        } catch (e) {
          return userClockinLocation!;
        }
      }
    }

    // If it's already a readable address or location name
    return userClockinLocation!;
  }

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

    final int? staffId =
        json['staffid'] != null
            ? int.tryParse(json['staffid'].toString())
            : null;
    final String? adminApprove = json['adminaprrove']?.toString();

    // Default flag logic:
    // - If completed (has clockin & clockout) → view only
    // - Else: keep previous behaviour (no edit/cancel when status == confirmed)
    final bool allowEditCancel = !isCompleted && status != 'confirmed';
    final staffFromDb = (json['staff_name'] ?? '').toString().trim();
    final staffFromReq = (json['staffreqname'] ?? '').toString().trim();

    final staffTypeDesignation =
        (json['stafftype_designation'] ??
                json['designation'] ??
                json['staff_type'] ??
                '')
            .toString()
            .trim();

    return ShiftItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      organizationName: json['organization_name'] ?? '',
      location: locationFull.trim(),
      date: json['date'] ?? '',
      time: timeRange.trim(),
      staffName: staffFromDb.isNotEmpty ? staffFromDb : staffFromReq,
      status: status,
      notes: json['notes'] ?? '',
      breakMinutes: json['break']?.toString() ?? '0',
      staffId: staffId,
      adminApprove: adminApprove,
      staffTypeDesignation: staffTypeDesignation, // ✅ NEW
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
      userClockinLocation: json['user_clockin_location']?.toString(),
    );
  }
}
