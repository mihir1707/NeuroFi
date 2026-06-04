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
  final _formKey          = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _phoneController  = TextEditingController();
  final _budgetController = TextEditingController();

  String _currency           = 'INR';
  bool   _notificationsEnabled = true;
  bool   _aiInsightsEnabled    = true;
  bool   _isLoading            = false;

  static const _currencyFlags = {
    'INR': '🇮🇳', 'USD': '🇺🇸', 'EUR': '🇪🇺', 'GBP': '🇬🇧',
    'AED': '🇦🇪', 'SGD': '🇸🇬', 'JPY': '🇯🇵', 'CAD': '🇨🇦', 'AUD': '🇦🇺',
  };

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text   = user.name;
      _phoneController.text  = user.phone;
      _budgetController.text =
          user.monthlyBudget > 0 ? user.monthlyBudget.toStringAsFixed(0) : '';
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
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));

    final user = context.read<AuthProvider>().user;
    if (user == null) { setState(() => _isLoading = false); return; }

    final updated = user.copyWith(
      name:                 _nameController.text.trim(),
      phone:                _phoneController.text.trim(),
      currency:             _currency,
      monthlyBudget:        double.tryParse(_budgetController.text) ?? 0,
      notificationsEnabled: _notificationsEnabled,
      aiInsightsEnabled:    _aiInsightsEnabled,
    );
    context.read<AuthProvider>().updateLocalUser(updated);

    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  // ── Login-style input decoration ────────────────────────────────────
  InputDecoration _buildDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: const Color.fromARGB(255, 133, 130, 130),
      ),
      floatingLabelStyle: AppTextStyles.labelMedium.copyWith(
        color: Colors.white,
        fontSize: 18,
      ),
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: const Color.fromARGB(255, 133, 130, 130),
      ),
      filled: true,
      fillColor: Colors.black,
      prefixIcon: Icon(icon,
          color: const Color.fromARGB(255, 209, 205, 205), size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 209, 205, 205)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 233, 226, 226)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            const BorderSide(color: Color.fromARGB(255, 223, 193, 193)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      errorStyle: AppTextStyles.labelSmall.copyWith(
        color: const Color.fromARGB(255, 223, 193, 193),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final initials = (user?.name ?? 'U')
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyles.headingSmall.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Avatar ──────────────────────────────────────────────
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
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
                        child: Text(
                          initials,
                          style: AppTextStyles.displayMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.darkBg0, width: 2),
                        ),
                        child: const Icon(Icons.edit,
                            color: AppColors.darkBg0, size: 14),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ── Full Name ───────────────────────────────────────────
              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color.fromRGBO(245, 247, 250, 1)),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  if (v.trim().length < 2) return 'Name must be at least 2 characters';
                  return null;
                },
                decoration: _buildDecoration(
                  label: 'Full Name',
                  hint: 'Enter your full name',
                  icon: Icons.person_outline_rounded,
                ),
              ),

              const SizedBox(height: 16),

              // ── Phone ───────────────────────────────────────────────
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color.fromRGBO(245, 247, 250, 1)),
                decoration: _buildDecoration(
                  label: 'Phone (optional)',
                  hint: '+91 98765 43210',
                  icon: Icons.phone_outlined,
                ),
              ),

              const SizedBox(height: 16),

              // ── Monthly Budget ──────────────────────────────────────
              TextFormField(
                controller: _budgetController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color.fromRGBO(245, 247, 250, 1)),
                decoration: _buildDecoration(
                  label: 'Monthly Budget',
                  hint: '0.00',
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),

              const SizedBox(height: 16),

              // ── Currency Dropdown ───────────────────────────────────
              DropdownButtonFormField<String>(
                value: _currency,
                decoration: _buildDecoration(
                  label: 'Default Currency',
                  hint: '',
                  icon: Icons.currency_exchange_rounded,
                ),
                dropdownColor: const Color(0xFF0B1E2D),
                style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color.fromRGBO(245, 247, 250, 1)),
                iconEnabledColor: const Color.fromARGB(255, 209, 205, 205),
                items: AppConstants.currencies
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Row(children: [
                            Text(_currencyFlags[c] ?? '🌍',
                                style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(c),
                          ]),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _currency = v ?? 'INR'),
              ),

              const SizedBox(height: 28),

              // ── Section label ────────────────────────────────────────
              Text(
                'Preferences',
                style: AppTextStyles.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 12),

              // ── Notification toggle ──────────────────────────────────
              _switchTile(
                title: 'Notifications',
                subtitle: 'Receive budget and spending alerts',
                icon: Icons.notifications_outlined,
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
              ),

              const SizedBox(height: 10),

              // ── AI Insights toggle ───────────────────────────────────
              _switchTile(
                title: 'AI Insights',
                subtitle: 'Get personalized spending insights',
                icon: Icons.auto_awesome_outlined,
                value: _aiInsightsEnabled,
                onChanged: (v) => setState(() => _aiInsightsEnabled = v),
              ),

              const SizedBox(height: 36),

              // ── Save button (login-style) ────────────────────────────
              GestureDetector(
                onTap: _isLoading ? null : _save,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: _isLoading
                        ? []
                        : [
                            BoxShadow(
                              color: const Color.fromARGB(255, 22, 22, 22),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Color.fromRGBO(245, 247, 250, 1),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: AppTextStyles.buttonText.copyWith(
                              color: const Color.fromRGBO(245, 247, 250, 1),
                              decorationColor: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Switch tile ──────────────────────────────────────────────────────
  Widget _switchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color.fromARGB(255, 233, 226, 226), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                color: const Color.fromARGB(255, 209, 205, 205), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color.fromRGBO(245, 247, 250, 1),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: const Color.fromARGB(255, 133, 130, 130),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.green,
            inactiveThumbColor: const Color.fromARGB(255, 133, 130, 130),
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}
