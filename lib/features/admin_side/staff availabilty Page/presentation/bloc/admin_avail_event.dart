abstract class AdminAvailabilityEvent {
  const AdminAvailabilityEvent();
}

class LoadAdminAvailabilityRange extends AdminAvailabilityEvent {
  final String startDate;
  final String endDate;
  final int? organiz;

  const LoadAdminAvailabilityRange({
    required this.startDate,
    required this.endDate,
    this.organiz,
  });
}
