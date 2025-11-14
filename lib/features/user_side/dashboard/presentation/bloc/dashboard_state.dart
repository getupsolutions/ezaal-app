abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final String userName;

  DashboardLoaded({required this.userName});
}

class DashboardNavigating extends DashboardState {
  final String destination;

  DashboardNavigating({required this.destination});
}
