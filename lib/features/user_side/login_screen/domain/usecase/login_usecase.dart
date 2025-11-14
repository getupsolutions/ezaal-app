import 'package:ezaal/features/user_side/login_screen/domain/Entity/user_entity.dart';
import 'package:ezaal/features/user_side/login_screen/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String email, String password) async {
    return await repository.login(email, password);
  }

  // Fetch current user from access token
  Future<UserEntity> getUserFromToken(String accessToken) async {
    return await repository.getUserFromToken(accessToken);
  }
}
