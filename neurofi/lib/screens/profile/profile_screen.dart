import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../router/route_names.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> _logout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A0A0A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x26FFFFFF)),
        ),
        title: Text('Sign Out',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
        content: Text('Are you sure you want to sign out?',
            style: AppTextStyles.bodyMedium
                .copyWith(color: Colors.white.withValues(alpha: 0.7))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',
                style: AppTextStyles.labelMedium
                    .copyWith(color: Colors.white.withValues(alpha: 0.6))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sign Out',
                style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, RouteNames.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildAvatar(user),
              const SizedBox(height: 20),
              _buildAccountSection(context, user),
              const SizedBox(height: 16),
              _buildPreferencesSection(context),
              const SizedBox(height: 16),
              _buildSupportSection(context),
              const SizedBox(height: 16),
              _buildLogoutButton(context),
              const SizedBox(height: 40),
              Text(
                'NeuroFi v1.0.0',
                style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.25)),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (Navigator.canPop(context))
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.arrow_back_ios_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            Text('Profile',
                style:
                    AppTextStyles.headingLarge.copyWith(color: Colors.white)),
          ],
        ),
        GestureDetector(
          onTap: () =>
              Navigator.pushNamed(context, RouteNames.notifications),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF0A0A0A),
              borderRadius: BorderRadius.circular(10),
              border: const Border.fromBorderSide(
                  BorderSide(color: Color(0x26FFFFFF))),
            ),
            child: const Icon(Icons.notifications_outlined,
                color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(UserModel? user) {
    final name = user?.name ?? 'User';
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    final email = user?.email ?? '';

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF111111),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x40FFFFFF), width: 2),
                boxShadow: [
                  BoxShadow(
                      color: Colors.white.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6)),
                ],
              ),
              child: Center(
                child: Text(initials,
                    style: AppTextStyles.displayMedium.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            GestureDetector(
              onTap: () =>
                  Navigator.pushNamed(context, RouteNames.editProfile),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Icon(Icons.edit_rounded,
                    size: 13, color: Colors.black),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(name,
            style: AppTextStyles.headingMedium
                .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(email,
            style: AppTextStyles.bodySmall
                .copyWith(color: Colors.white.withValues(alpha: 0.5))),
        if (user?.currency != null) ...[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border:
                  Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(user!.currency,
                style: AppTextStyles.labelSmall
                    .copyWith(color: Colors.white.withValues(alpha: 0.7))),
          ),
        ],
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context, UserModel? user) {
    return _Section(
      title: 'Account',
      items: [
        _SettingItem(
          icon: Icons.person_outline_rounded,
          label: 'Edit Profile',
          onTap: () => Navigator.pushNamed(context, RouteNames.editProfile),
        ),
        _SettingItem(
          icon: Icons.lock_outline_rounded,
          label: 'Change Password',
          onTap: () =>
              Navigator.pushNamed(context, RouteNames.changePassword),
        ),
        _SettingItem(
          icon: Icons.currency_exchange_rounded,
          label: 'Default Currency',
          value: user?.currency ?? 'INR',
          onTap: () => Navigator.pushNamed(context, RouteNames.editProfile),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context) {
    return _Section(
      title: 'Preferences',
      items: [
        _SettingItem(
          icon: Icons.category_outlined,
          label: 'Categories',
          onTap: () => Navigator.pushNamed(context, RouteNames.categories),
        ),
        _SettingItem(
          icon: Icons.notifications_outlined,
          label: 'Notifications',
          onTap: () =>
              Navigator.pushNamed(context, RouteNames.notifications),
        ),
      ],
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return _Section(
      title: 'About',
      items: [
        _SettingItem(
          icon: Icons.info_outline_rounded,
          label: 'App Version',
          value: '1.0.0',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _logout(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Sign Out',
                style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<_SettingItem> items;
  const _Section({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(title,
              style: AppTextStyles.labelMedium
                  .copyWith(color: Colors.white.withValues(alpha: 0.4))),
        ),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A),
            borderRadius: BorderRadius.circular(16),
            border: const Border.fromBorderSide(
                BorderSide(color: Color(0x26FFFFFF))),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  _buildRow(e.value),
                  if (!isLast)
                    const Divider(
                        height: 1,
                        color: Color(0x1AFFFFFF),
                        indent: 52),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(_SettingItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(item.label,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: Colors.white)),
            ),
            if (item.value != null)
              Text(item.value!,
                  style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white.withValues(alpha: 0.5))),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withValues(alpha: 0.3), size: 16),
          ],
        ),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;
  const _SettingItem(
      {required this.icon,
      required this.label,
      this.value,
      required this.onTap});
}