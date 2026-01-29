import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_buttons.dart';
import 'package:ezaal/core/widgets/custom_textformfield.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/screen/dashboard_page.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/screen/admin_dashboardscreen.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_event.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return BlocConsumer<AuthBloc, AuthState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: kWhite,
          body: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/Logo/Media.png',
                      height: screenHeight * 0.10,
                    ),
                    SizedBox(height: screenHeight * 0.07),

                    Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: screenHeight * 0.030,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      'Please login to your account to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        color: kGrey,
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.05),

                    // Single identifier field (Email/Username)
                    CustomTextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: identifierController,
                      labelText: 'Email or Username',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email or Username cannot be empty';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    CustomTextFormField(
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      controller: passwordController,
                      labelText: 'Password',
                      isPassword: true,
                      obscureText: _obscurePassword,
                      onToggleVisibility: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: screenHeight * 0.04),

                    state is AuthLoading
                        ? const CircularProgressIndicator()
                        : CustomRoundedButton(
                          label: 'Login',
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthBloc>().add(
                                LoginRequested(
                                  identifierController.text.trim(),
                                  passwordController.text.trim(),
                                ),
                              );
                            }
                          },
                          backgroundColor: primaryColor,
                        ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Automatically route based on user role
          if (state.user.isAdmin) {
            NavigatorHelper.pushReplacement(const AdminDashboardPage());
          } else {
            NavigatorHelper.pushReplacement(const DashboardView());
          }
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
    );
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
