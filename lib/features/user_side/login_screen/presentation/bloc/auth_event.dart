abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String identifier; // Can be email or username
  final String password;

  LoginRequested(this.identifier, this.password);
}

class LogoutRequested extends AuthEvent {}

class AppStarted extends AuthEvent {}
