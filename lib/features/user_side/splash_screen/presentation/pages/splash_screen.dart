import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/screen/dashboard_page.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/pages/login_screen.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/bloc/splash_bloc.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/bloc/splash_event.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/bloc/splash_state.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/widget/splash_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _handleNavigation(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay
    final token = await TokenStorage.getAccessToken();

    if (token != null && token.isNotEmpty) {
      NavigatorHelper.pushReplacement(DashboardView());
    } else {
      NavigatorHelper.pushReplacement(const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start splash event
    context.read<SplashBloc>().add(StartSplash());
    _handleNavigation(context);

    // final screenWidth = MediaQuery.of(context).size.width;
    // final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: kWhite,
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashCompleted) {
            //Navigator Helper
            NavigatorHelper.push(LoginScreen());
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            double imageWidth = constraints.maxWidth * 0.5;
            double imageHeight = constraints.maxHeight * 0.3;

            return Center(
              child: SizedBox(
                width: imageWidth,
                height: imageHeight,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SplashLogoAnimation(
                    child: Image.asset('assets/Logo/Media.jpeg'),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
