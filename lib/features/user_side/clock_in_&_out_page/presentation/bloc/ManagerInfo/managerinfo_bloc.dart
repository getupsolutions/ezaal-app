import 'package:ezaal/features/user_side/clock_in_&_out_page/domain/usecase/managerinfo_usecase.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_event.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ManagerInfoBloc extends Bloc<ManagerInfoEvent, ManagerInfoState> {
  final SubmitManagerInfoUseCase submitManagerInfoUseCase;

  ManagerInfoBloc({required this.submitManagerInfoUseCase})
    : super(ManagerInfoInitial()) {
    on<SubmitManagerInfoRequested>(_onSubmitManagerInfoRequested);
  }

  Future<void> _onSubmitManagerInfoRequested(
    SubmitManagerInfoRequested event,
    Emitter<ManagerInfoState> emit,
  ) async {
    debugPrint('=== BLOC: Submit Manager Info Requested ===');
    debugPrint('Request ID: ${event.requestID}');
    debugPrint('Manager Name: ${event.managerName}');
    debugPrint('Designation: ${event.managerDesignation}');
    debugPrint('Signature size: ${event.signatureBytes.length} bytes');

    emit(ManagerInfoLoading());
    debugPrint('State emitted: ManagerInfoLoading');

    try {
      await submitManagerInfoUseCase(
        requestID: event.requestID,
        managerName: event.managerName,
        managerDesignation: event.managerDesignation,
        signatureBytes: event.signatureBytes,
      );
      debugPrint('✅ Manager info use case completed successfully');
      emit(ManagerInfoSuccess());
      debugPrint('State emitted: ManagerInfoSuccess');
    } catch (e) {
      debugPrint('❌ Manager info error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      emit(ManagerInfoFailure(e.toString()));
      debugPrint('State emitted: ManagerInfoFailure');
    }
    debugPrint('==========================================');
  }
}
