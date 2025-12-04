class ShiftItem {
  final int id;
  final String organizationName;
  final String location; // street + suburb + postcode
  final String date; // 'yyyy-MM-dd'
  final String time; // 'HH:mm - HH:mm'
  final String staffName; // may be empty if not assigned
  final String status; // 'un-confirm', 'confirmed', etc.

  // Flags to control icons
  final bool hasEdit;
  final bool hasCancel;
  final bool hasAdd;
  final bool hasView;
  final bool hasDocument;

  ShiftItem({
    required this.id,
    required this.organizationName,
    required this.location,
    required this.date,
    required this.time,
    required this.staffName,
    required this.status,
    this.hasEdit = true,
    this.hasCancel = true,
    this.hasAdd = false,
    this.hasView = true,
    this.hasDocument = false,
  });

  factory ShiftItem.fromJson(Map<String, dynamic> json) {
    final locationFull =
        (json['location_full'] as String?) ??
        '${json['street'] ?? ''}, ${json['suburb'] ?? ''} ${json['postcode'] ?? ''}';

    final timeRange =
        (json['time_range'] as String?) ??
        '${json['fromtime'] ?? ''} - ${json['totime'] ?? ''}';

    final status = (json['status'] as String?) ?? '';

    return ShiftItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      organizationName: json['organization_name'] ?? '',
      location: locationFull.trim(),
      date: json['date'] ?? '',
      time: timeRange.trim(),
      staffName:
          json['staffreqname'] ?? json['staff_name'] ?? '', // from DB columns
      status: status,
      // Decide icon flags based on status
      hasEdit: status != 'confirmed',
      hasCancel: status != 'confirmed',
      hasAdd: false,
      hasView: true,
      hasDocument: false,
    );
  }
}
