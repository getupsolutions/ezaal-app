import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/core/widgets/svg_imageviewer.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/screen/shift_managmentscreen.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/pages/availableshift_page.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/pages/clockin_out_page.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_state.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/pages/user_details_page.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/pages/roster_page.dart';
import 'package:ezaal/features/user_side/timesheet_page/presentation/screen/timesheet_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
  bool isFirstDropdownExpanded = false;
  bool isSecondDropdownExpanded = false;
  int selectedIndex = -1; // Default no selection

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://getupsolutions.in');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Show error if URL can't be launched
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open website'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: primaryDarK,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;

            // Responsive sizes
            final horizontalPadding = width * 0.04;
            final verticalPadding = height * 0.015;
            final avatarSize = width * 0.25;
            final titleFontSize = width * 0.045;
            final subtitleFontSize = width * 0.04;
            final iconSize = width * 0.10;

            return Column(
              children: [
                // Drawer Header
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    // Default guest values
                    String name = "Guest";
                    String email = "guest@example.com";
                    String? typeId;
                    String? photoUrl;

                    // Check if user is logged in
                    if (state is AuthSuccess) {
                      name = state.user.name;
                      email = state.user.email;
                      typeId = state.user.staffId;
                      photoUrl = state.user.photoUrl;
                    } else if (state is AuthLoading) {
                      // Show loading indicator while checking auth
                      return Padding(
                        padding: EdgeInsets.all(horizontalPadding),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(horizontalPadding),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(width * 0.03),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: avatarSize,
                                height: avatarSize,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(height: verticalPadding),
                              Text(
                                'Loading...',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: EdgeInsets.all(horizontalPadding),
                      child: GestureDetector(
                        onTap:
                            state is AuthSuccess
                                ? () => NavigatorHelper.push(UserDetailsPage())
                                : null,
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(horizontalPadding),
                          decoration: BoxDecoration(
                            color: kWhite,
                            borderRadius: BorderRadius.circular(width * 0.03),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ClipOval(
                                child:
                                    photoUrl != null
                                        ? Image.network(
                                          photoUrl,
                                          width: avatarSize,
                                          height: avatarSize,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (_, __, ___) => Icon(
                                                Icons.person,
                                                size: avatarSize,
                                              ),
                                        )
                                        : Icon(Icons.person, size: avatarSize),
                              ),
                              SizedBox(height: verticalPadding),
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                ),
                              ),
                              SizedBox(height: verticalPadding / 2),
                              Text(
                                email,
                                style: TextStyle(fontSize: subtitleFontSize),
                              ),
                              if (typeId != null)
                                Text(
                                  typeId,
                                  style: TextStyle(
                                    fontSize: subtitleFontSize,
                                    color: kPurple,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: verticalPadding),

                // Scrollable Menu
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          leading: SVGImageView(
                            image: 'assets/svg/nav_dashboard.svg',
                            width: iconSize,
                            height: iconSize,
                            color: Colors.white,
                          ),
                          title: Text(
                            ' Dashboard',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: kWhite,
                              fontSize: titleFontSize,
                            ),
                          ),
                          onTap: () => NavigatorHelper.pop(),
                        ),
                        ListTile(
                          leading: SVGImageView(
                            image: 'assets/svg/my_roster.svg',
                            width: iconSize,
                            height: iconSize,
                            color: Colors.white,
                          ),
                          title: Text(
                            'Shift Management',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: kWhite,
                              fontSize: titleFontSize,
                            ),
                          ),
                          onTap:
                              () =>
                                  NavigatorHelper.push(ShiftManagmentscreen()),
                        ),
                      ],
                    ),
                  ),
                ),

                // Developer credit at the bottom
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: verticalPadding * 2,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Divider(
                          color: Colors.white.withOpacity(0.3),
                          thickness: 1,
                        ),
                        SizedBox(height: verticalPadding),
                        GestureDetector(
                          onTap: _launchURL,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Developed by ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: subtitleFontSize,
                                ),
                              ),
                              Text(
                                'GetUp Solutions',
                                style: TextStyle(
                                  color: Colors.blue[300],
                                  fontSize: subtitleFontSize,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
