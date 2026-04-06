import 'package:ezaal/core/services/fcm_service.dart';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/features/user_side/login_screen/data/models/login_model.dart';
import 'package:ezaal/features/user_side/login_screen/domain/usecase/login_usecase.dart';
import 'package:flutter/rendering.dart';
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
          await FCMService().syncTokenToServer(
            accessToken: storedUser.accessToken,
            baseUrl: FCMConfig.baseUrl,
          );
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
            final userModel = UserModel.fromEntity(user);

            await TokenStorage.saveUserData(userModel);

            await FCMService().syncTokenToServer(
              accessToken: accessToken,
              baseUrl: FCMConfig.baseUrl,
            );

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
        final user = await loginUseCase.autoLogin(
          event.identifier,
          event.password,
        );

        await TokenStorage.saveTokens(user.accessToken, user.refreshToken);

        final userModel = UserModel.fromEntity(user);
        await TokenStorage.saveUserData(userModel);

        // Force sync on fresh login — token may have rotated since last session
        await FCMService().syncTokenToServer(
          accessToken: user.accessToken,
          baseUrl: FCMConfig.baseUrl,
          force: true, // 👈 always push on login
        );

        emit(AuthSuccess(user));
      } catch (e) {
        emit(AuthFailure(e.toString()));
      }
    });

    on<LogoutRequested>((event, emit) async {
      emit(AuthLoading());

      try {
        // Grab token BEFORE clearing storage
        final accessToken = await TokenStorage.getAccessToken();

        if (accessToken != null && accessToken.isNotEmpty) {
          // Remove FCM token from server so no pushes are sent after logout
          await FCMService().deleteTokenFromServer(
            accessToken: accessToken,
            baseUrl: FCMConfig.baseUrl,
          );
        }
      } catch (e) {
        // Non-fatal — proceed with logout regardless
        debugPrint('⚠️ FCM token cleanup failed during logout: $e');
      }

      await TokenStorage.clearTokens();
      emit(AuthInitial());
    });
  }
}
