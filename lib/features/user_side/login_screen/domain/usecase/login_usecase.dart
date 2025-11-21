import 'package:ezaal/features/user_side/login_screen/domain/Entity/user_entity.dart';
import 'package:ezaal/features/user_side/login_screen/domain/repository/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(
    String identifier,
    String password, {
    bool isAdmin = false,
  }) async {
    return await repository.login(identifier, password, isAdmin: isAdmin);
  }

  // Auto-detect login: Try admin first, then user
  Future<UserEntity> autoLogin(String identifier, String password) async {
    return await repository.autoLogin(identifier, password);
  }

  // Fetch current user from access token
  Future<UserEntity> getUserFromToken(String accessToken) async {
    return await repository.getUserFromToken(accessToken);
  }
}
