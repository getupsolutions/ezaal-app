import 'package:ezaal/features/admin_side/admin_dashboard/domain/usecase/notification_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkAsReadUseCase markAsReadUseCase;
  final MarkAllAsReadUseCase markAllAsReadUseCase;
  final DeleteNotificationUseCase deleteNotificationUseCase;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markAsReadUseCase,
    required this.markAllAsReadUseCase,
    required this.deleteNotificationUseCase,
  }) : super(NotificationInitial()) {
    on<FetchNotifications>(_fetchNotifications);
    on<FetchUnreadCount>(_fetchUnreadCount);
    on<MarkNotificationAsRead>(_markAsRead);
    on<MarkAllNotificationsAsRead>(_markAllAsRead);
    on<DeleteNotification>(_deleteNotification);
    on<RefreshNotifications>(_refreshNotifications);
  }

  Future<void> _fetchNotifications(
    FetchNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(NotificationLoading());
    try {
      final notifications = await getNotificationsUseCase();
      final unreadCount = await getUnreadCountUseCase();

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      print('Error fetching notifications: $e');

      if (e.toString().contains('Session expired')) {
        emit(NotificationSessionExpired());
      } else {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _fetchUnreadCount(
    FetchUnreadCount event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final unreadCount = await getUnreadCountUseCase();

      if (state is NotificationLoaded) {
        final currentState = state as NotificationLoaded;
        emit(
          NotificationLoaded(
            notifications: currentState.notifications,
            unreadCount: unreadCount,
          ),
        );
      }
    } catch (e) {
      print('Error fetching unread count: $e');
    }
  }

  Future<void> _markAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await markAsReadUseCase(event.notificationId);
      emit(NotificationMarkedAsRead(event.notificationId));

      final notifications = await getNotificationsUseCase();
      final unreadCount = await getUnreadCountUseCase();

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      print('Error marking notification as read: $e');

      if (e.toString().contains('Session expired')) {
        emit(NotificationSessionExpired());
      } else {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _markAllAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await markAllAsReadUseCase();
      emit(AllNotificationsMarkedAsRead());

      final notifications = await getNotificationsUseCase();
      final unreadCount = await getUnreadCountUseCase();

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      print('Error marking all notifications as read: $e');

      if (e.toString().contains('Session expired')) {
        emit(NotificationSessionExpired());
      } else {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _deleteNotification(
    DeleteNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await deleteNotificationUseCase(event.notificationId);
      emit(NotificationDeleted(event.notificationId));

      final notifications = await getNotificationsUseCase();
      final unreadCount = await getUnreadCountUseCase();

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      print('Error deleting notification: $e');

      if (e.toString().contains('Session expired')) {
        emit(NotificationSessionExpired());
      } else {
        emit(NotificationError(e.toString()));
      }
    }
  }

  Future<void> _refreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final notifications = await getNotificationsUseCase();
      final unreadCount = await getUnreadCountUseCase();

      emit(
        NotificationLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ),
      );
    } catch (e) {
      print('Error refreshing notifications: $e');
    }
  }
}
