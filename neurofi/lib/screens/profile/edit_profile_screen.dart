import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController    = TextEditingController();
  final _phoneController   = TextEditingController();
  final _budgetController  = TextEditingController();
  String _currency         = 'INR';
  bool _notificationsEnabled = true;
  bool _aiInsightsEnabled    = true;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text   = user.name;
      _phoneController.text  = user.phone;
      _budgetController.text = user.monthlyBudget > 0 ? user.monthlyBudget.toStringAsFixed(0) : '';
      _currency              = user.currency;
      _notificationsEnabled  = user.notificationsEnabled;
      _aiInsightsEnabled     = user.aiInsightsEnabled;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final updated = user.copyWith(
      name:                 _nameController.text.trim(),
      phone:                _phoneController.text.trim(),
      currency:             _currency,
      monthlyBudget:        double.tryParse(_budgetController.text) ?? 0,
      notificationsEnabled: _notificationsEnabled,
      aiInsightsEnabled:    _aiInsightsEnabled,
    );
    context.read<AuthProvider>().updateLocalUser(updated);
    if (mounted) Navigator.pop(context);
  }

  InputDecoration get _inputDec => InputDecoration(
    filled: true,
    fillColor: AppColors.darkBg1,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
  );

  static const _currencyFlags = {
    'INR': '🇮🇳', 'USD': '🇺🇸', 'EUR': '🇪🇺', 'GBP': '🇬🇧',
    'AED': '🇦🇪', 'SGD': '🇸🇬', 'JPY': '🇯🇵', 'CAD': '🇨🇦', 'AUD': '🇦🇺',
  };

  @override
  Widget build(BuildContext context) {
    final user     = context.watch<AuthProvider>().user;
    final initials = (user?.name ?? 'U').trim().split(' ')
        .take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Edit Profile',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _save,
            child: Text('Save',
                style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.sage, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green],
                    begin: Alignment.topLeft, end: Alignment.bottomRight),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(initials,
                  style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.lightGrey, fontWeight: FontWeight.w700))),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
              decoration: _inputDec.copyWith(
                labelText: 'Full Name',
                prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.darkText3, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
              decoration: _inputDec.copyWith(
                labelText: 'Phone (optional)',
                prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.darkText3, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
              decoration: _inputDec.copyWith(
                labelText: 'Monthly Budget',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.darkText3, size: 18),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _currency,
              decoration: _inputDec.copyWith(labelText: 'Default Currency'),
              dropdownColor: AppColors.darkBg1,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
              items: AppConstants.currencies.map((c) => DropdownMenuItem(
                value: c,
                child: Row(children: [
                  Text(_currencyFlags[c] ?? '🌍', style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(c),
                ]),
              )).toList(),
              onChanged: (v) => setState(() => _currency = v ?? 'INR'),
            ),
            const SizedBox(height: 24),
            _switchTile('Notifications', 'Receive budget and spending alerts',
                Icons.notifications_outlined, _notificationsEnabled,
                (v) => setState(() => _notificationsEnabled = v)),
            const SizedBox(height: 10),
            _switchTile('AI Insights', 'Get personalized spending insights',
                Icons.auto_awesome_outlined, _aiInsightsEnabled,
                (v) => setState(() => _aiInsightsEnabled = v)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _switchTile(String title, String subtitle, IconData icon, bool value,
      ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.forest.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.sage, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.lightGrey, fontWeight: FontWeight.w600)),
                Text(subtitle, style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.darkText3)),
              ],
            ),
          ),
          Switch(value: value, activeColor: AppColors.green, onChanged: onChanged),
        ],
      ),
    );
  }
}
