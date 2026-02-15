import 'package:ezaal/features/user_side/dashboard/presentation/bloc/staff_noti_bloc.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/staff_noti_event.dart';
import 'package:ezaal/features/user_side/dashboard/presentation/bloc/staff_noti_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationUIPage extends StatefulWidget {
  const NotificationUIPage({super.key});

  @override
  State<NotificationUIPage> createState() => _NotificationUIPageState();
}

class _NotificationUIPageState extends State<NotificationUIPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    context.read<StaffNotificationBloc>().add(FetchStaffNotifications());
    context.read<StaffNotificationBloc>().add(FetchStaffUnreadCount());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    // Simple readable format without extra packages
    String two(int n) => n.toString().padLeft(2, '0');
    final d = '${two(dt.day)}-${two(dt.month)}-${dt.year}';
    final t = '${two(dt.hour)}:${two(dt.minute)}';
    return '$d • $t';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        title: const Text('Staff Notifications'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<StaffNotificationBloc>().add(
                FetchStaffNotifications(),
              );
              context.read<StaffNotificationBloc>().add(
                FetchStaffUnreadCount(),
              );
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<StaffNotificationBloc, StaffNotificationState>(
          builder: (context, state) {
            // Error state (if you have error in state)
            if ((state.error ?? '').isNotEmpty) {
              return _ErrorState(
                message: state.error!,
                onRetry: () {
                  context.read<StaffNotificationBloc>().add(
                    FetchStaffNotifications(),
                  );
                  context.read<StaffNotificationBloc>().add(
                    FetchStaffUnreadCount(),
                  );
                },
              );
            }

            final q = _searchCtrl.text.trim().toLowerCase();
            final filtered =
                state.staffNotifications.where((n) {
                  final matchesSearch =
                      q.isEmpty || n.notification.toLowerCase().contains(q);
                  final matchesUnread = !_showUnreadOnly || n.isUnread;
                  return matchesSearch && matchesUnread;
                }).toList();

            return Column(
              children: [
                // Top summary + controls
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                  child: Column(
                    children: [
                      _TopSummaryCard(
                        unreadCount: state.staffUnreadCount,
                        totalCount: state.staffNotifications.length,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _SearchField(
                              controller: _searchCtrl,
                              onChanged: (_) => setState(() {}),
                              onClear: () {
                                _searchCtrl.clear();
                                setState(() {});
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          _UnreadToggleChip(
                            selected: _showUnreadOnly,
                            onTap:
                                () => setState(
                                  () => _showUnreadOnly = !_showUnreadOnly,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child:
                      state.loading
                          ? const _LoadingList()
                          : RefreshIndicator(
                            onRefresh: () async {
                              context.read<StaffNotificationBloc>().add(
                                FetchStaffNotifications(),
                              );
                              context.read<StaffNotificationBloc>().add(
                                FetchStaffUnreadCount(),
                              );
                            },
                            child:
                                filtered.isEmpty
                                    ? _EmptyState(
                                      isSearching:
                                          q.isNotEmpty || _showUnreadOnly,
                                      onClearFilters: () {
                                        _searchCtrl.clear();
                                        _showUnreadOnly = false;
                                        setState(() {});
                                      },
                                    )
                                    : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                        14,
                                        6,
                                        14,
                                        14,
                                      ),
                                      physics:
                                          const AlwaysScrollableScrollPhysics(),
                                      itemCount: filtered.length,
                                      separatorBuilder:
                                          (_, __) => const SizedBox(height: 10),
                                      itemBuilder: (context, i) {
                                        final n = filtered[i];
                                        return _NotificationCard(
                                          title: n.notification,
                                          dateText: _formatDate(n.addedOn),
                                          isUnread: n.isUnread,
                                          onTap: () {
                                            // You can navigate using n.link if you add it
                                            // For now just show details
                                            showModalBottomSheet(
                                              context: context,
                                              backgroundColor: Colors.white,
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            18,
                                                          ),
                                                        ),
                                                  ),
                                              builder:
                                                  (_) =>
                                                      _NotificationDetailSheet(
                                                        title: 'Notification',
                                                        message: n.notification,
                                                        dateText: _formatDate(
                                                          n.addedOn,
                                                        ),
                                                        isUnread: n.isUnread,
                                                      ),
                                            );
                                          },
                                        );
                                      },
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

/// ==========================
/// UI WIDGETS
/// ==========================

class _TopSummaryCard extends StatelessWidget {
  final int unreadCount;
  final int totalCount;

  const _TopSummaryCard({required this.unreadCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_rounded, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Updates for you',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unreadCount unread • $totalCount total',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                unreadCount > 99 ? '99+ new' : '$unreadCount new',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search notifications...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon:
            controller.text.isEmpty
                ? null
                : IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.blue.withOpacity(0.5)),
        ),
      ),
    );
  }
}

class _UnreadToggleChip extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;

  const _UnreadToggleChip({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.blue.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                selected
                    ? Colors.blue.withOpacity(0.35)
                    : Colors.grey.withOpacity(0.15),
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.mark_email_unread_rounded
                  : Icons.mark_email_read_rounded,
              size: 18,
              color: selected ? Colors.blue : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              'Unread',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.blue : Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String dateText;
  final bool isUnread;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.dateText,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.10)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeadingDot(isUnread: isUnread),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight:
                            isUnread ? FontWeight.w800 : FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            dateText,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey[500],
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
  }
}

class _LeadingDot extends StatelessWidget {
  final bool isUnread;
  const _LeadingDot({required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 38,
      decoration: BoxDecoration(
        color:
            isUnread
                ? Colors.red.withOpacity(0.12)
                : Colors.grey.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        isUnread
            ? Icons.notifications_active_rounded
            : Icons.notifications_none_rounded,
        size: 20,
        color: isUnread ? Colors.red : Colors.grey[700],
      ),
    );
  }
}

class _NotificationDetailSheet extends StatelessWidget {
  final String title;
  final String message;
  final String dateText;
  final bool isUnread;

  const _NotificationDetailSheet({
    required this.title,
    required this.message,
    required this.dateText,
    required this.isUnread,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isUnread)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Unread',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dateText,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isSearching;
  final VoidCallback onClearFilters;

  const _EmptyState({required this.isSearching, required this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 70),
        Icon(Icons.inbox_rounded, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 14),
        Center(
          child: Text(
            isSearching ? 'No results found' : 'No staff notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.grey[800],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            isSearching
                ? 'Try clearing search / filters.'
                : 'You’re all caught up for now.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (isSearching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70),
            child: OutlinedButton(
              onPressed: onClearFilters,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Clear filters'),
            ),
          ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 56, color: Colors.red[400]),
            const SizedBox(height: 12),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.grey[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) {
        return Container(
          height: 82,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.12)),
          ),
        );
      },
    );
  }
}
