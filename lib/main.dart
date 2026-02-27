// import 'package:ezaal/core/presentation/pages/home_page/screens/home_screen.dart';
// import 'package:ezaal/core/presentation/pages/organization_page/bloc/org_bloc.dart';
// import 'package:ezaal/core/presentation/pages/splash_screen/bloc/splash_bloc.dart';
// import 'package:ezaal/core/presentation/utils/navigator_helper.dart';
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/services/fcm_service.dart';
import 'package:ezaal/core/services/notification_polling.dart';
import 'package:ezaal/core/services/notification_service.dart';
import 'package:ezaal/core/token_manager.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/bloc/notification_event.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/bloc/admin_avail_bloc.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/bloc/notification_bloc.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/staff_noti_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_bloc.dart';
import 'package:ezaal/features/user_side/login_screen/presentation/bloc/auth_event.dart';
import 'package:ezaal/features/user_side/roster_page/presentation/bloc/roster_bloc.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/bloc/splash_bloc.dart';
import 'package:ezaal/features/user_side/splash_screen/presentation/pages/splash_screen.dart';
import 'package:ezaal/features/user_side/staff_availbility_page/presentation/bloc/availbility_bloc.dart';
import 'package:ezaal/features/user_side/timesheet_page/presentation/bloc/timesheet_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:ezaal/core/di/di.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ 1. Initialize local notifications FIRST
  await LocalNotificationService().initialize();

  // ✅ 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ 3. Register the TOP-LEVEL background handler (NOT a static class method)
  //    This is the most critical fix — the handler must be a top-level function
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ 4. Initialize FCM service (foreground handling, permissions, channels)
  await FCMService().init();

  // ✅ 5. Debug: print FCM token
  final fmtoken = await FirebaseMessaging.instance.getToken();
  debugPrint('🔥 FCM TOKEN => $fmtoken');

  // ✅ 6. Initialize dependency injection
  await di.init();

  // ✅ 7. Get stored token and launch app
  String? token = await TokenStorage.getAccessToken();
  runApp(MyApp(initialToken: token));
}

class MyApp extends StatefulWidget {
  final String? initialToken;

  const MyApp({super.key, this.initialToken});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late NotificationPollingService _pollingService;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
    _checkInitialConnectivity();
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _handleConnectivityChange(results);
    });
  }

  Future<void> _startPolling() async {
    try {
      await _pollingService.startPolling(intervalSeconds: 30);
    } catch (e) {
      debugPrint('❌ Error starting polling: $e');
    }
  }

  Future<void> _checkInitialConnectivity() async {
    final isOnline = await OfflineQueueService.isOnline();
    setState(() {
      _isOnline = isOnline;
    });

    if (isOnline) {
      _syncOfflineOperations();
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) async {
    final wasOffline = !_isOnline;
    final isNowOnline = results.first != ConnectivityResult.none;

    setState(() {
      _isOnline = isNowOnline;
    });

    // If device just came online, sync
    if (wasOffline && isNowOnline) {
      debugPrint('🌐 Device back online - triggering sync');
      _syncOfflineOperations();
    } else if (!isNowOnline) {
      debugPrint('📴 Device went offline');
    }
  }

  Future<void> _syncOfflineOperations() async {
    final queueCount = await OfflineQueueService.getQueueCount();

    if (queueCount == 0) {
      debugPrint('✅ No offline operations to sync');
      return;
    }

    debugPrint('🔄 Syncing $queueCount offline operations...');

    try {
      final syncService = di.sl<OfflineSyncService>();
      final result = await syncService.syncAllOperations();

      if (result['success']) {
        debugPrint('✅ All offline operations synced successfully');

        // Show notification to user
        if (mounted && NavigatorHelper.navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(
            NavigatorHelper.navigatorKey.currentContext!,
          ).showSnackBar(
            SnackBar(
              content: Text(
                '✅ ${result['synced']} offline operation(s) synced successfully',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        debugPrint('⚠️ Some operations failed to sync');

        // Show notification about partial sync
        if (mounted && NavigatorHelper.navigatorKey.currentContext != null) {
          ScaffoldMessenger.of(
            NavigatorHelper.navigatorKey.currentContext!,
          ).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error during sync: $e');
    }
  }

  @override
  void dispose() {
    _pollingService.stopPolling();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()..add(AppStarted())),
        BlocProvider(create: (context) => di.sl<SplashBloc>()),
        BlocProvider(create: (context) => di.sl<ShiftBloc>()),
        BlocProvider(create: (context) => di.sl<RosterBloc>()),
        BlocProvider(create: (context) => di.sl<AttendanceBloc>()),
        BlocProvider(create: (context) => di.sl<SlotBloc>()),
        BlocProvider(create: (context) => di.sl<ManagerInfoBloc>()),
        BlocProvider(create: (context) => di.sl<TimesheetBloc>()),
        BlocProvider(create: (context) => di.sl<DashboardBloc>()),
        BlocProvider(
          create:
              (context) => di.sl<NotificationBloc>()..add(FetchNotifications()),
        ),
        BlocProvider(create: (context) => di.sl<AdminShiftBloc>()),
        BlocProvider(create: (context) => di.sl<AvailabilityBloc>()),
        BlocProvider(create: (context) => di.sl<AdminAvailabilityBloc>()),
        BlocProvider(create: (context) => di.sl<StaffNotificationBloc>()),
      ],
      child: MaterialApp(
        navigatorKey: NavigatorHelper.navigatorKey,
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Stack(
            children: [
              child!,
              if (!_isOnline)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: danger,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off, color: kWhite, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Offline Mode - Data will sync when online',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
