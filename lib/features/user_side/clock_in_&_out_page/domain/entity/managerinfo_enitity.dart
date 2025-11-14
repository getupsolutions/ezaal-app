import 'dart:typed_data';

class ManagerInfoEntity {
  final String requestID;
  final String managerName;
  final String managerDesignation;
  final Uint8List signatureBytes;

  const ManagerInfoEntity({
    required this.requestID,
    required this.managerName,
    required this.managerDesignation,
    required this.signatureBytes,
  });
}


