import 'package:ezaal/features/user_side/login_screen/domain/Entity/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(
    String identifier,
    String password, {
    bool isAdmin = false,
  });

  Future<UserEntity> autoLogin(String identifier, String password);

  Future<UserEntity> getUserFromToken(String accessToken);
}
