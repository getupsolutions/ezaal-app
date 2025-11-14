abstract class ManagerInfoState {}

class ManagerInfoInitial extends ManagerInfoState {}

class ManagerInfoLoading extends ManagerInfoState {}

class ManagerInfoSuccess extends ManagerInfoState {}

class ManagerInfoFailure extends ManagerInfoState {
  final String message;
  ManagerInfoFailure(this.message);
}
