import 'dart:typed_data';

abstract class ManagerInfoRepository {
  Future<void> submitManagerInfo({
    required String requestID,
    required String managerName,
    required String managerDesignation,
    required Uint8List signatureBytes,
  });
}
