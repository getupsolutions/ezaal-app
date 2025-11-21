import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/screen/dashboard_page.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/screen/admin_dashboardscreen.dart';
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
    final userData = await TokenStorage.getUserData();

    if (token != null && token.isNotEmpty && userData != null) {
      // Check user role and navigate accordingly
      if (userData.isAdmin) {
        NavigatorHelper.pushReplacement(const AdminDashboardPage());
      } else {
        NavigatorHelper.pushReplacement(const DashboardView());
      }
    } else {
      // No token or user data, navigate to login
      NavigatorHelper.pushReplacement(const LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Start splash event
    context.read<SplashBloc>().add(StartSplash());
    _handleNavigation(context);

    return Scaffold(
      backgroundColor: kWhite,
      body: BlocListener<SplashBloc, SplashState>(
        listener: (context, state) {
          if (state is SplashCompleted) {
            // Navigation is already handled by _handleNavigation
            // This listener can be used for additional splash completion logic if needed
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
