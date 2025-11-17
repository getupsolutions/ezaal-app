import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/widgets/custom_drawer.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/widget/dashboard_widgets.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 900;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[100],
      drawer: CustomDrawer(),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu, color: kWhite),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        backgroundColor: primaryDarK,
        elevation: 0,
        // leading: const Icon(Icons.menu, color: Colors.black87),
        title:
            isSmallScreen
                ? Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      buildEzaalLogo(isSmallScreen: isSmallScreen),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'EHC Hub',
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: buildEzaalLogo(isSmallScreen: isSmallScreen),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'EHC Hub',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        actions: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              String userName = 'User';
              String? photoUrl;

              if (state is AuthSuccess) {
                // Trim and capitalize full name properly
                userName = state.user.name.trim();
                photoUrl = state.user.photoUrl;
              }

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(50),
                  onTap: () {
                    // You can navigate to Profile Page or show a menu here later
                  },
                  hoverColor: Colors.grey.withOpacity(0.1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: isSmallScreen ? 18 : 20,
                        backgroundImage:
                            (photoUrl != null && photoUrl.isNotEmpty)
                                ? NetworkImage(photoUrl)
                                : null,
                        child:
                            (photoUrl == null || photoUrl.isEmpty)
                                ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 20,
                                )
                                : null,
                      ),
                      const SizedBox(width: 10),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isSmallScreen ? 100 : 140,
                        ),
                        child: Text(
                          userName,
                          style: TextStyle(
                            color: kWhite,
                            fontWeight: FontWeight.w600,
                            fontSize: isSmallScreen ? 14 : 16,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isSmallScreen) ...[
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocListener<DashboardBloc, DashboardState>(
        listener: (context, state) {
          if (state is DashboardNavigating) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Navigating to ${state.destination}'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Dashboard',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isSmallScreen)
                    TextButton(
                      onPressed: () {},
                      child: const Text('Dashboard'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 24.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Desktop: 3 columns
                    if (constraints.maxWidth > 900) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: buildAvailableShiftCard(context)),
                          const SizedBox(width: 16),
                          Expanded(child: buildMyRosterCard(context)),
                          const SizedBox(width: 16),
                          Expanded(child: buildClockInOutCard(context)),
                        ],
                      );
                    }
                    // Tablet: 2 columns
                    else if (constraints.maxWidth > 600) {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: buildAvailableShiftCard(context),
                                ),
                                const SizedBox(width: 16),
                                Expanded(child: buildMyRosterCard(context)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            buildClockInOutCard(context),
                          ],
                        ),
                      );
                    }
                    // Mobile: 1 column
                    else {
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            buildAvailableShiftCard(context),
                            const SizedBox(height: 12),
                            buildMyRosterCard(context),
                            const SizedBox(height: 12),
                            buildClockInOutCard(context),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              color: const Color(0xFF1F2937),
              child: Center(
                child: Text(
                  'All rights reserved by Ezaal Healthcare',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
