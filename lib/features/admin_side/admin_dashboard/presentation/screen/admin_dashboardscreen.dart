import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_event.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure you want to logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              );

              if (confirm == true && context.mounted) {
                context.read<AuthBloc>().add(LogoutRequested());
                NavigatorHelper.pushReplacement(const LoginScreen());
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: TokenStorage.getUserData().then((user) => user?.name),
        builder: (context, snapshot) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.admin_panel_settings,
                  size: 100,
                  color: primaryColor,
                ),
                const SizedBox(height: 20),
                Text(
                  'Welcome, ${snapshot.data ?? "Admin"}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Admin Portal',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 40),
                // Add your admin-specific widgets here
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    children: [
                      _buildAdminCard(
                        icon: Icons.people,
                        title: 'Manage Users',
                        onTap: () {
                          // Navigate to manage users
                        },
                      ),
                      _buildAdminCard(
                        icon: Icons.schedule,
                        title: 'Manage Shifts',
                        onTap: () {
                          // Navigate to manage shifts
                        },
                      ),
                      _buildAdminCard(
                        icon: Icons.analytics,
                        title: 'Reports',
                        onTap: () {
                          // Navigate to reports
                        },
                      ),
                      _buildAdminCard(
                        icon: Icons.settings,
                        title: 'Settings',
                        onTap: () {
                          // Navigate to settings
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: primaryColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
