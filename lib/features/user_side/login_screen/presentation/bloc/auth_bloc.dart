import 'package:ezaal/core/services/fcm_service.dart';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/features/user_side/login_screen/data/models/login_model.dart';
import 'package:ezaal/features/user_side/login_screen/domain/usecase/login_usecase.dart';
import 'package:flutter/foundation.dart';
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
          final authType = storedUser.isAdmin ? 'admin' : 'user';

          await TokenStorage.saveAuthType(authType);

          await FCMService().setLoginContext(
            accessToken: storedUser.accessToken,
            authType: authType,
          );

          await FCMService().syncTokenToServerIfLoggedIn();

          emit(AuthSuccess(storedUser));
          return;
        }

        final accessToken = await TokenStorage.getAccessToken();
        final refreshToken = await TokenStorage.getRefreshToken();
        final savedAuthType = await TokenStorage.getAuthType();

        if (accessToken != null &&
            refreshToken != null &&
            accessToken.isNotEmpty) {
          try {
            final user = await loginUseCase.getUserFromToken(accessToken);
            final userModel = UserModel.fromEntity(user);

            await TokenStorage.saveUserData(userModel);

            final authType = savedAuthType ?? (user.isAdmin ? 'admin' : 'user');

            await TokenStorage.saveAuthType(authType);

            await FCMService().setLoginContext(
              accessToken: accessToken,
              authType: authType,
            );

            await FCMService().syncTokenToServerIfLoggedIn();

            emit(AuthSuccess(user));
          } catch (e) {
            await FCMService().clearLoginContext();
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
        final user = await loginUseCase.autoLogin(
          event.identifier,
          event.password,
        );

        final authType = user.isAdmin ? 'admin' : 'user';

        await TokenStorage.saveTokens(user.accessToken, user.refreshToken);
        await TokenStorage.saveAuthType(authType);

        final userModel = UserModel.fromEntity(user);
        await TokenStorage.saveUserData(userModel);

        await FCMService().setLoginContext(
          accessToken: user.accessToken,
          authType: authType,
        );

        await FCMService().syncTokenToServerIfLoggedIn(force: true);

        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        await FCMService().logoutCleanup();
      } catch (e) {
        debugPrint('⚠️ FCM token cleanup failed during logout: $e');
      }

      await TokenStorage.clearTokens();
      emit(AuthInitial());
    });
  }
}
