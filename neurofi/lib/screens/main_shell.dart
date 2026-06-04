import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../providers/auth_provider.dart';
import '../router/route_names.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions/transactions_screen.dart';
import 'analytics/analytics_screen.dart';
import 'accounts/accounts_screen.dart';
import 'profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;

  late AnimationController _fabController;
  late Animation<double>   _fabScale;
  late Animation<double>   _fabRotate;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionsScreen(),
    AnalyticsScreen(),
    AccountsScreen(),
    ProfileScreen(),
  ];

  final List<_NavItem> _navItems = const [
    _NavItem(
      icon:         Icons.home_outlined,
      activeIcon:   Icons.home_rounded,
      label:        'Home',
    ),
    _NavItem(
      icon:         Icons.swap_horiz_outlined,
      activeIcon:   Icons.swap_horiz_rounded,
      label:        'History',
    ),
    _NavItem(
      icon:         Icons.bar_chart_outlined,
      activeIcon:   Icons.bar_chart_rounded,
      label:        'Analytics',
    ),
    _NavItem(
      icon:         Icons.account_balance_wallet_outlined,
      activeIcon:   Icons.account_balance_wallet_rounded,
      label:        'Accounts',
    ),
    _NavItem(
      icon:         Icons.person_outline_rounded,
      activeIcon:   Icons.person_rounded,
      label:        'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 300),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );
    _fabRotate = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeOut),
    );
    _fabController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadUser();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }

  void _onFabTap() {
    HapticFeedback.mediumImpact();
    _fabController.reverse().then((_) {
      Navigator.pushNamed(context, RouteNames.addTransaction)
          .then((_) => _fabController.forward());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScale,
        child: RotationTransition(
          turns: _fabRotate,
          child: GestureDetector(
            onTap: _onFabTap,
            child: Container(
              width:  58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:      Colors.white.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset:     const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.black,
                size:  28,
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(
        currentIndex: _currentIndex,
        items:        _navItems,
        onTap:        _onTabTap,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int              currentIndex;
  final List<_NavItem>   items;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: Colors.black,
        border: const Border(
          top: BorderSide(color: Color(0x26FFFFFF), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withValues(alpha: 0.6),
            blurRadius: 20,
            offset:     const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _buildNavItems(context, items.sublist(0, 2)),
            const SizedBox(width: 72),
            _buildNavItems(context, items.sublist(3, 5), startIndex: 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItems(BuildContext context, List<_NavItem> navItems, {int startIndex = 0}) {
    return Expanded(
      child: Row(
        children: List.generate(navItems.length, (i) {
          final index    = startIndex + i;
          final item     = navItems[i];
          final selected = currentIndex == index;

          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap:    () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve:    Curves.easeOut,
                    padding:  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      selected ? item.activeIcon : item.icon,
                      size:  selected ? 24 : 22,
                      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize:   10,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                      color:      selected ? Colors.white : Colors.white.withValues(alpha: 0.35),
                    ),
                    child: Text(item.label),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String   label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}