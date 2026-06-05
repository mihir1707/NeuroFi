import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../core/utils/date_formatter.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  List<NotificationModel> _filterGroup(
      List<NotificationModel> all, String group) {
    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    return all.where((n) {
      final d = DateTime.tryParse(n.createdAt ?? '') ?? now;
      final day = DateTime(d.year, d.month, d.day);
      if (group == 'Today')     return day == today;
      if (group == 'Yesterday') return day == yesterday;
      return day.isBefore(yesterday);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider      = context.watch<NotificationProvider>();
    final notifications = provider.notifications;
    final isLoading     = provider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Notifications',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
        actions: [
          if (provider.hasUnread)
            TextButton(
              onPressed: () => provider.markAllAsRead(),
              child: Text('Mark all read',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.sage)),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.green))
          : notifications.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh: () => provider.loadNotifications(),
                  color: AppColors.green,
                  backgroundColor: AppColors.darkBg1,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    children: [
                      for (final group in ['Today', 'Yesterday', 'Earlier']) ...[
                        ..._buildGroup(group, _filterGroup(notifications, group), provider),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
    );
  }

  List<Widget> _buildGroup(String label, List<NotificationModel> items,
      NotificationProvider provider) {
    if (items.isEmpty) return [];
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(label,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
      ),
      ...items.map((n) => _NotifTile(n: n,
          onTap: () => provider.markAsRead(n.id))),
    ];
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔔', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText2)),
          const SizedBox(height: 6),
          Text("You're all caught up!",
              style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3)),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final NotificationModel n;
  final VoidCallback onTap;
  const _NotifTile({required this.n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = n.type == 'budget_alert' ? AppColors.amber
        : n.type == 'goal_update' ? AppColors.green
        : n.type == 'group_expense' ? AppColors.peach
        : AppColors.sage;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: n.isRead ? AppColors.darkBg1.withValues(alpha: 0.4) : typeColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: n.isRead ? AppColors.darkBorder.withValues(alpha: 0.5) : typeColor.withValues(alpha: 0.3),
              width: n.isRead ? 1 : 1.5),
          boxShadow: n.isRead ? [] : [
            BoxShadow(
              color: typeColor.withValues(alpha: 0.05),
              blurRadius: 12,
              spreadRadius: 2,
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: n.isRead ? AppColors.darkBg0 : typeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: n.isRead ? AppColors.darkBorder : typeColor.withValues(alpha: 0.4),
                ),
              ),
              child: Center(child: Text(n.icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: n.isRead ? AppColors.lightGrey.withValues(alpha: 0.8) : Colors.white,
                          fontWeight: n.isRead ? FontWeight.w500 : FontWeight.w700,
                          fontSize: 16,
                          letterSpacing: 0.2)),
                  const SizedBox(height: 6),
                  Text(n.body,
                      style: AppTextStyles.bodySmall.copyWith(
                          color: n.isRead ? AppColors.darkText3 : AppColors.darkText2,
                          height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded, size: 12, color: AppColors.darkText3),
                      const SizedBox(width: 4),
                      Text(
                        n.createdAt != null ? DateFormatter.toRelative(n.createdAt!) : '',
                        style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 10, height: 10, margin: const EdgeInsets.only(top: 6, left: 8),
                decoration: BoxDecoration(
                  color: typeColor, 
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: typeColor.withValues(alpha: 0.6), blurRadius: 6, spreadRadius: 1)
                  ]
                ),
              ),
          ],
        ),
      ),
    );
  }
}
