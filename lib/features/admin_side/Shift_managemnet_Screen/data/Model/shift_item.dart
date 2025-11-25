class ShiftItem {
  final String location;
  final String date;
  final String time;
  final String staffName;
  final bool hasEdit;
  final bool hasCancel;
  final bool hasAdd;
  final bool hasView;
  final bool hasDocument;

  ShiftItem({
    required this.location,
    required this.date,
    required this.time,
    required this.staffName,
    this.hasEdit = false,
    this.hasCancel = false,
    this.hasAdd = false,
    this.hasView = false,
    this.hasDocument = false,
  });
}
