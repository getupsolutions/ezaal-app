class AvailabilityEntity {
  final DateTime date;
  final String? amFrom, amTo;
  final String? pmFrom, pmTo;
  final String? n8From, n8To;
  final String? notes; 
  final int? organiz;

  const AvailabilityEntity({
    required this.date,
    this.amFrom,
    this.amTo,
    this.pmFrom,
    this.pmTo,
    this.n8From,
    this.n8To,
    this.notes, 
    this.organiz,
  });
}
