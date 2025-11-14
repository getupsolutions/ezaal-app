import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/features/user_side/login_screen/data/models/login_model.dart';
import 'package:ezaal/features/user_side/login_screen/domain/usecase/login_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc(this.loginUseCase) : super(AuthInitial()) {
    on<AppStarted>((event, emit) async {
      emit(AuthLoading());

      try {
        final storedUser = await TokenStorage.getUserData();

        if (storedUser != null && storedUser.accessToken.isNotEmpty) {
          emit(AuthSuccess(storedUser));
          return;
        }

        final accessToken = await TokenStorage.getAccessToken();
        final refreshToken = await TokenStorage.getRefreshToken();

        if (accessToken != null &&
            refreshToken != null &&
            accessToken.isNotEmpty) {
          try {
            final user = await loginUseCase.getUserFromToken(accessToken);

            // Convert UserEntity to UserModel before saving
            final userModel = UserModel.fromEntity(user);
            await TokenStorage.saveUserData(userModel);

            emit(AuthSuccess(user));
          } catch (e) {
            await TokenStorage.clearTokens();
            emit(AuthInitial());
          }
        } else {
          emit(AuthInitial());
        }
      } catch (e) {
        emit(AuthInitial());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await loginUseCase(event.email, event.password);

        await TokenStorage.saveTokens(user.accessToken, user.refreshToken);

        // Convert UserEntity to UserModel before saving
        final userModel = UserModel.fromEntity(user);
        await TokenStorage.saveUserData(userModel);

        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await TokenStorage.clearTokens();
      emit(AuthInitial());
    });
  }
}
