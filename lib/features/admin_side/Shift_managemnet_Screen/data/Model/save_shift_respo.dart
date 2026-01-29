class SaveShiftResponse {
  final bool? mailSent;
  final String? mailTo;
  final String? mailReason;

  const SaveShiftResponse({this.mailSent, this.mailTo, this.mailReason});

  factory SaveShiftResponse.fromJson(Map<String, dynamic> json) {
    final mail = json['mail'];
    if (mail is Map<String, dynamic>) {
      return SaveShiftResponse(
        mailSent: mail['sent'] == true,
        mailTo: mail['to']?.toString(),
        mailReason: mail['reason']?.toString(),
      );
    }
    return const SaveShiftResponse();
  }
}
