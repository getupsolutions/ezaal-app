import 'package:ezaal/features/user_side/login_screen/domain/Entity/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> getUserFromToken(String accessToken);
}
