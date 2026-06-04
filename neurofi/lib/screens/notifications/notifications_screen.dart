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
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: n.isRead ? AppColors.darkBg1 : AppColors.darkBg1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: n.isRead ? AppColors.darkBorder : typeColor.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Text(n.icon, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(n.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.lightGrey,
                          fontWeight: n.isRead ? FontWeight.w400 : FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(n.body,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText2),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(
                    n.createdAt != null ? DateFormatter.toRelative(n.createdAt!) : '',
                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3),
                  ),
                ],
              ),
            ),
            if (!n.isRead)
              Container(
                width: 8, height: 8, margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }
}
