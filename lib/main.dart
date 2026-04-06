import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ezaal/core/constant/constant.dart';
import 'package:ezaal/core/di/di.dart' as di;
import 'package:ezaal/core/services/fcm_service.dart';
import 'package:ezaal/core/widgets/navigator_helper.dart';
import 'package:ezaal/features/admin_side/Shift_managemnet_Screen/presentation/bloc/Admin%20Shift/admin_shift_bloc.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/bloc/notification_bloc.dart';
import 'package:ezaal/features/admin_side/admin_dashboard/presentation/bloc/notification_event.dart';
import 'package:ezaal/features/admin_side/staff%20availabilty%20Page/presentation/bloc/admin_avail_bloc.dart';
import 'package:ezaal/features/user_side/available_shift_page/presentation/bloc/shift_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/ManagerInfo/managerinfo_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/Slot_Bloc/slot_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/bloc/attendance_bloc.dart';
import 'package:ezaal/features/user_side/clock_in_&_out_page/presentation/widget/queded_operation.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/staff_noti_bloc.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/staff_noti_event.dart';
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
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('🚀 main started');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('🚀 firebase initialized');

  // Background handler must be registered before runApp — keep this here
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  debugPrint('🚀 bg handler registered');

  await di.init();
  debugPrint('🚀 di done');

  // ✅ FIX 1: Don't await FCMService.init() before runApp.
  // Permission dialogs + token fetch + HTTP sync were blocking the main thread
  // and causing the "Skipped 45 frames" warning. Defer to after first frame.
  runApp(const MyApp());
  debugPrint('🚀 runApp called');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = false;

  DateTime? _lastUserNotificationRefreshAt;
  DateTime? _lastStaffNotificationRefreshAt;

  static const Duration _notificationRefreshCooldown = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _initConnectivityListener();
    _checkInitialConnectivity();

    // ✅ FIX 2: All heavy startup work in a single post-frame callback.
    // Added a small delay so the splash screen fully paints before any
    // async work (FCM init, permission dialog, token HTTP sync) begins.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Init FCM first (requests permission, sets up listeners, gets token)
      await FCMService().init();
      debugPrint('🚀 fcm init done');

      // Attach UI callbacks only after FCM is ready
      _attachFcmCallbacks();

      // Small breathing room before the first network call
      await Future.delayed(const Duration(milliseconds: 200));

      // Sync token if user is already logged in from a previous session
      await FCMService().syncTokenToServerIfLoggedIn();
    });
  }

  void _attachFcmCallbacks() {
    final fcm = FCMService();

    fcm.onUserMessage = (title, body, type) {
      debugPrint('👤 User push callback: $title | $body | $type');
      _dispatchUserNotification(title, body, type);
    };

    fcm.onStaffMessage = (title, body, type) {
      debugPrint('👨‍⚕️ Staff push callback: $title | $body | $type');
      _dispatchStaffNotification(title, body, type);
    };
  }

  bool _shouldRunUserRefresh() {
    final now = DateTime.now();
    if (_lastUserNotificationRefreshAt == null ||
        now.difference(_lastUserNotificationRefreshAt!) >
            _notificationRefreshCooldown) {
      _lastUserNotificationRefreshAt = now;
      return true;
    }
    return false;
  }

  bool _shouldRunStaffRefresh() {
    final now = DateTime.now();
    if (_lastStaffNotificationRefreshAt == null ||
        now.difference(_lastStaffNotificationRefreshAt!) >
            _notificationRefreshCooldown) {
      _lastStaffNotificationRefreshAt = now;
      return true;
    }
    return false;
  }

  void _dispatchUserNotification(String title, String body, String type) {
    final currentContext = NavigatorHelper.navigatorKey.currentContext;
    if (currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dispatchUserNotification(title, body, type);
      });
      return;
    }

    if (_shouldRunUserRefresh()) {
      currentContext.read<NotificationBloc>().add(RefreshNotifications());
    } else {
      debugPrint('ℹ️ Skipping duplicate user notification refresh');
    }

    ScaffoldMessenger.of(currentContext).showSnackBar(
      SnackBar(
        content: Text(title.isNotEmpty ? title : 'New notification received'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _dispatchStaffNotification(String title, String body, String type) {
    final currentContext = NavigatorHelper.navigatorKey.currentContext;
    if (currentContext == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _dispatchStaffNotification(title, body, type);
      });
      return;
    }

    if (_shouldRunStaffRefresh()) {
      currentContext.read<StaffNotificationBloc>().add(FetchStaffUnreadCount());
      currentContext.read<StaffNotificationBloc>().add(
        FetchStaffNotifications(),
      );
      currentContext.read<NotificationBloc>().add(RefreshNotifications());
    } else {
      debugPrint('ℹ️ Skipping duplicate staff notification refresh');
    }

    ScaffoldMessenger.of(currentContext).showSnackBar(
      SnackBar(
        content: Text(title.isNotEmpty ? title : 'New staff notification'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _initConnectivityListener() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _handleConnectivityChange(results);
    });
  }

  Future<void> _checkInitialConnectivity() async {
    final isOnline = await OfflineQueueService.isOnline();
    if (!mounted) return;
    setState(() => _isOnline = isOnline);
    if (isOnline) await _syncOfflineOperations();
  }

  Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final wasOffline = !_isOnline;
    final isNowOnline =
        results.isNotEmpty && results.first != ConnectivityResult.none;

    if (!mounted) return;
    setState(() => _isOnline = isNowOnline);

    if (wasOffline && isNowOnline) {
      debugPrint('🌐 Device back online - triggering sync');
      await _syncOfflineOperations();
      await FCMService().syncTokenToServerIfLoggedIn();
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
      final ctx = NavigatorHelper.navigatorKey.currentContext;

      if (!mounted || ctx == null) return;

      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            result['success']
                ? '✅ ${result['synced']} offline operation(s) synced successfully'
                : result['message'],
          ),
          backgroundColor: result['success'] ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );

      if (result['success']) {
        debugPrint('✅ All offline operations synced successfully');
      } else {
        debugPrint('⚠️ Some operations failed to sync');
      }
    } catch (e) {
      debugPrint('❌ Error during sync: $e');
    }
  }

  @override
  void dispose() {
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
          // ✅ FIX 3: NotificationBloc — don't fire FetchNotifications here.
          // AuthBloc's AppStarted will emit AuthSuccess once the user is
          // confirmed logged in; trigger the fetch from the dashboard/screen
          // that actually needs it, not globally at app start.
          create: (context) => di.sl<NotificationBloc>(),
        ),
        BlocProvider(create: (context) => di.sl<AdminShiftBloc>()),
        BlocProvider(create: (context) => di.sl<AvailabilityBloc>()),
        BlocProvider(create: (context) => di.sl<AdminAvailabilityBloc>()),
        BlocProvider(
          // ✅ FIX 4: StaffNotificationBloc — only fetch unread count eagerly
          // (fast, single int endpoint). Defer the full notification list to
          // the screen that renders it, avoiding a heavy list fetch on every
          // cold start before we even know if the user is logged in.
          create:
              (context) =>
                  di.sl<StaffNotificationBloc>()..add(FetchStaffUnreadCount()),
        ),
      ],
      child: MaterialApp(
        navigatorKey: NavigatorHelper.navigatorKey,
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
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
                        children: const [
                          Icon(Icons.cloud_off, color: Colors.white, size: 16),
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
