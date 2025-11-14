import 'package:ezaal/features/user_side/splash_screen/presentation/bloc/splash_event.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/bloc/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(SplashInital()) {
    on<StartSplash>((event, emit) async {
      await Future.delayed(Duration(seconds: 3));
      emit(SplashCompleted());
    });
  }
}
