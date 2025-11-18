abstract class ManagerInfoState {}

class ManagerInfoInitial extends ManagerInfoState {}

class ManagerInfoLoading extends ManagerInfoState {}

class ManagerInfoSuccess extends ManagerInfoState {
  final bool isOfflineQueued;
  ManagerInfoSuccess({this.isOfflineQueued = false}); // ✅ Added this line
}

class ManagerInfoFailure extends ManagerInfoState {
  final String message;
  ManagerInfoFailure(this.message);
}
