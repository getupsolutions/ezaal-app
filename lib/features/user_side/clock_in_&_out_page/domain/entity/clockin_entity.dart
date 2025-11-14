class ClockInEntity {
  final String requestID;
  final String inTime;
  final String signintype; // 'on-time', 'early', 'late'
  final String signinreason;

  const ClockInEntity({
    required this.requestID,
    required this.inTime,
    required this.signintype,
    required this.signinreason,
  });
}
