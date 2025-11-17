import 'dart:ui';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/core/widgets/show_dialog.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_event.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_state.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserDetailsPage extends StatelessWidget {
  const UserDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthSuccess) {
            final user = state.user;

            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0F2027),
                    Color(0xFF203A43),
                    Color(0xFF2C5364),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    // Main Content
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),

                          // Profile Avatar with Neon Glow
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [Color(0xFF00C9FF), Color(0xFF92FE9D)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withAlpha(109),
                                  blurRadius: 25,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child:
                                  user.photoUrl != null &&
                                          user.photoUrl!.isNotEmpty
                                      ? Image.network(
                                        user.photoUrl!,
                                        width: 130,
                                        height: 130,
                                        fit: BoxFit.cover,
                                      )
                                      : const Icon(
                                        Icons.person,
                                        size: 120,
                                        color: Colors.white,
                                      ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Name and Email
                          Text(
                            user.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.white.withAlpha(109),
                              fontSize: 16,
                            ),
                          ),
                          if (user.staffId != null)
                            Text(
                              "Staff ID: ${user.staffId}",
                              style: TextStyle(
                                color: Colors.white.withAlpha(109),
                                fontSize: 14,
                              ),
                            ),

                          const SizedBox(height: 40),

                          // Glass Cards
                          _buildGlassCard(
                            icon: Icons.person_outline,
                            title: "Full Name",
                            value: user.name,
                          ),
                          _buildGlassCard(
                            icon: Icons.email_outlined,
                            title: "Email Address",
                            value: user.email,
                          ),
                          if (user.staffId != null)
                            _buildGlassCard(
                              icon: Icons.badge_outlined,
                              title: "Staff ID",
                              value: user.staffId!,
                            ),

                          const SizedBox(height: 60),

                          // Stylish Back Button
                          ElevatedButton.icon(
                            onPressed: () {
                              CupertinoDialogUtils.showCupertinoDialogBox(
                                context: context,
                                title: 'Logout',
                                content: 'Are you sure you want to logout?',
                                actions: [
                                  CupertinoDialogActionModel(
                                    child: const Text('Cancel'),
                                    onPressed:
                                        () => Navigator.of(context).pop(),
                                    isDefaultAction: true,
                                  ),
                                  CupertinoDialogActionModel(
                                    child: const Text('Logout'),
                                    onPressed: () {
                                      context.read<AuthBloc>().add(
                                        LogoutRequested(),
                                      );
                                      NavigatorHelper.pushReplacement(
                                        const LoginScreen(),
                                      );
                                    },
                                    isDestructiveAction: true,
                                  ),
                                ],
                              );
                            },
                            icon: const Icon(Icons.arrow_back_ios_new_rounded),
                            label: const Text(
                              "Log Out",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withAlpha(1095),
                              foregroundColor: Colors.white,
                              shadowColor: Colors.white.withAlpha(109),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 45,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Floating Back Button (top-left)
                    Positioned(
                      top: 16,
                      left: 10,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(1095),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(109),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => NavigatorHelper.pop(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: Text(
              "User not logged in",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          );
        },
      ),
    );
  }

  // Glassmorphism Info Card
  Widget _buildGlassCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(50),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withAlpha(109)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(1095),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white.withAlpha(109),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: TextStyle(
                          color: Colors.white.withAlpha(100),
                          fontSize: 14.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
