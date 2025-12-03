import 'package:ezaal/core/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationBloc>().add(FetchNotifications());
  }

  IconData _getIconForNotificationType(String type) {
    switch (type) {
      case 'shift-approved':
        return Icons.check_circle;
      case 'shift-rejected':
        return Icons.cancel;
      case 'new-shift':
        return Icons.event_available;
      case 'shift-claim-pending':
        return Icons.pending_actions;
      default:
        return Icons.notifications;
    }
  }

  Color _getColorForNotificationType(String type) {
    switch (type) {
      case 'shift-approved':
        return Colors.green;
      case 'shift-rejected':
        return Colors.red;
      case 'new-shift':
        return Colors.blue;
      case 'shift-claim-pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryDarK,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: kWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: kWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: kWhite),
            onPressed: () {
              context.read<NotificationBloc>().add(RefreshNotifications());
            },
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: kWhite),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                context.read<NotificationBloc>().add(
                  MarkAllNotificationsAsRead(),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => [
                  PopupMenuItem(
                    value: 'mark_all_read',
                    child: Row(
                      children: [
                        Icon(Icons.done_all, color: primaryColor),
                        SizedBox(width: 8),
                        Text('Mark all as read'),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationMarkedAsRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Notification marked as read'),
                duration: Duration(seconds: 1),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AllNotificationsMarkedAsRead) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('All notifications marked as read'),
                duration: Duration(seconds: 2),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is NotificationDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Notification deleted'),
                duration: Duration(seconds: 1),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is NotificationSessionExpired) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Session expired. Please login again.'),
                backgroundColor: Colors.red,
              ),
            );
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return Center(
              child: CircularProgressIndicator(color: primaryColor),
            );
          } else if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_none,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'You\'ll see updates about your shifts here',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationBloc>().add(RefreshNotifications());
              },
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: state.notifications.length,
                itemBuilder: (context, index) {
                  final notification = state.notifications[index];
                  final color = _getColorForNotificationType(notification.type);
                  final icon = _getIconForNotificationType(notification.type);

                  return Dismissible(
                    key: Key(notification.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 20),
                      margin: EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      context.read<NotificationBloc>().add(
                        DeleteNotification(notification.id),
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        if (notification.isUnread) {
                          context.read<NotificationBloc>().add(
                            MarkNotificationAsRead(notification.id),
                          );
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color:
                              notification.isUnread
                                  ? color.withOpacity(0.05)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                notification.isUnread
                                    ? color.withOpacity(0.3)
                                    : Colors.grey[200]!,
                            width: notification.isUnread ? 2 : 1,
                          ),
                          boxShadow: [
                            if (notification.isUnread)
                              BoxShadow(
                                color: color.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(icon, color: color, size: 24),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _getNotificationTitle(
                                            notification.type,
                                          ),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      if (notification.isUnread)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: color,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            'NEW',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    notification.notification,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.access_time,
                                        size: 14,
                                        color: Colors.grey[600],
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        timeago.format(notification.addedOn),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Error loading notifications',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  SizedBox(height: 8),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<NotificationBloc>().add(
                        FetchNotifications(),
                      );
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Center(child: Text('No notifications'));
        },
      ),
    );
  }

  String _getNotificationTitle(String type) {
    switch (type) {
      case 'shift-approved':
        return 'Shift Approved ✓';
      case 'shift-rejected':
        return 'Shift Rejected';
      case 'new-shift':
        return 'New Shift Available';
      case 'shift-claim-pending':
        return 'Shift Claim Pending';
      default:
        return 'Notification';
    }
  }
}
