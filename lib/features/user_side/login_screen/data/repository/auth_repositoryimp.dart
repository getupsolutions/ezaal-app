import 'package:ezaal/features/user_side/login_screen/data/data_source/auth_remotedatasource.dart';
import 'package:ezaal/features/user_side/login_screen/domain/Entity/user_entity.dart';
import 'package:ezaal/features/user_side/login_screen/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<UserEntity> getUserFromToken(String accessToken) async {
    return await remoteDataSource.getUserFromToken(accessToken);
  }
}
