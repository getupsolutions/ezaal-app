late String formattedDate;
late String formattedTime;

void updateDateTime() {
  final now = DateTime.now();
  formattedDate = "${now.day}-${now.month}-${now.year}";
  formattedTime =
      "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
}
