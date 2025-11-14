class ClockOutEntity {
  final String requestID;
  final String outTime;
  final String signouttype; // 'on-time', 'early', 'late'
  final String signoutreason;
  final String shiftbreak;

  const ClockOutEntity({
    required this.requestID,
    required this.outTime,
    required this.signouttype,
    required this.signoutreason,
    required this.shiftbreak,
  });
}
