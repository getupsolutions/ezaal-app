import 'dart:typed_data';

abstract class ManagerInfoEvent {}

class SubmitManagerInfoRequested extends ManagerInfoEvent {
  final String requestID;
  final String managerName;
  final String managerDesignation;
  final Uint8List signatureBytes;

  SubmitManagerInfoRequested({
    required this.requestID,
    required this.managerName,
    required this.managerDesignation,
    required this.signatureBytes,
  });
}
