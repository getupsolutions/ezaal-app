import 'dart:typed_data';
import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/repository/managerinfo_repository.dart';
import 'package:flutter/material.dart';

class SubmitManagerInfoUseCase {
  final ManagerInfoRepository repository;

  SubmitManagerInfoUseCase(this.repository);

  Future<void> call({
    required String requestID,
    required String managerName,
    required String managerDesignation,
    required Uint8List signatureBytes,
  }) async {
    debugPrint('=== USE CASE: Submit Manager Info ===');
    debugPrint('Request ID: $requestID');
    debugPrint('Manager Name: $managerName');
    debugPrint('Manager Designation: $managerDesignation');
    debugPrint('Signature size: ${signatureBytes.length} bytes');
    debugPrint('====================================');

    try {
      await repository.submitManagerInfo(
        requestID: requestID,
        managerName: managerName,
        managerDesignation: managerDesignation,
        signatureBytes: signatureBytes,
      );
      debugPrint('✅ Repository submit completed');
    } catch (e) {
      debugPrint('❌ Repository submit failed: $e');
      rethrow;
    }
  }
}
