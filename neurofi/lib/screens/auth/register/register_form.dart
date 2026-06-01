import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../router/route_names.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey                   = GlobalKey<FormState>();
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _phoneController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool   _obscurePassword = true;
  bool   _obscureConfirm  = true;
  String _selectedCurrency = 'INR';

  final List<Map<String, String>> _currencies = const [
    {'code': 'INR', 'label': '🇮🇳  INR — Indian Rupee'},
    {'code': 'USD', 'label': '🇺🇸  USD — US Dollar'},
    {'code': 'EUR', 'label': '🇪🇺  EUR — Euro'},
    {'code': 'GBP', 'label': '🇬🇧  GBP — British Pound'},
    {'code': 'AED', 'label': '🇦🇪  AED — UAE Dirham'},
    {'code': 'SGD', 'label': '🇸🇬  SGD — Singapore Dollar'},
    {'code': 'JPY', 'label': '🇯🇵  JPY — Japanese Yen'},
    {'code': 'CAD', 'label': '🇨🇦  CAD — Canadian Dollar'},
    {'code': 'AUD', 'label': '🇦🇺  AUD — Australian Dollar'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final auth    = context.read<AuthProvider>();
    final success = await auth.register(
      name:     _nameController.text.trim(),
      email:    _emailController.text.trim(),
      password: _passwordController.text,
      currency: _selectedCurrency,
      phone:    _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration failed. Please try again.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller:         _nameController,
            textInputAction:    TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            style:     AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
            validator: Validators.name,
            decoration: _buildDecoration(
              label: 'Full Name',
              hint:  'Mihir Khunt',
              icon:  Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller:      _emailController,
            keyboardType:    TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style:     AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
            validator: Validators.email,
            decoration: _buildDecoration(
              label: 'Email Address',
              hint:  'mihirkhunt45@gmail.com',
              icon:  Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller:      _phoneController,
            keyboardType:    TextInputType.phone,
            textInputAction: TextInputAction.next,
            style:     AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
            validator: Validators.phone,
            decoration: _buildDecoration(
              label: 'Phone Number (optional)',
              hint:  '+91 98765 43210',
              icon:  Icons.phone_outlined,
            ),
          ),
          const SizedBox(height: 16),
          _currencyDropdown(),
          const SizedBox(height: 16),
          TextFormField(
            controller:      _passwordController,
            obscureText:     _obscurePassword,
            textInputAction: TextInputAction.next,
            style:     AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
            validator: Validators.password,
            decoration: _buildDecoration(
              label:  'Password',
              hint:   'Min. 8 characters',
              icon:   Icons.lock_outline_rounded,
              suffix: _eyeButton(
                isObscure: _obscurePassword,
                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller:       _confirmPasswordController,
            obscureText:      _obscureConfirm,
            textInputAction:  TextInputAction.done,
            onFieldSubmitted: (_) => _submit(),
            style:     AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
            validator: (val) => Validators.confirmPassword(val, _passwordController.text),
            decoration: _buildDecoration(
              label:  'Confirm Password',
              hint:   'Re-enter your password',
              icon:   Icons.lock_outline_rounded,
              suffix: _eyeButton(
                isObscure: _obscureConfirm,
                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _registerButton(isLoading),
          const SizedBox(height: 24),
          _divider(),
          const SizedBox(height: 20),
          _loginLink(),
        ],
      ),
    );
  }

  Widget _currencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.darkBg1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.currency_exchange_outlined, color: AppColors.darkText3, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:         _selectedCurrency,
                isExpanded:    true,
                dropdownColor: AppColors.darkBg2,
                menuMaxHeight: 280,
                hint: Text(
                  'Default Currency',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText3),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.darkText3,
                  size: 22,
                ),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                items: _currencies.map((c) {
                  return DropdownMenuItem<String>(
                    value: c['code'],
                    child: Text(
                      c['label']!,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCurrency = val);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width:  double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [AppColors.forest.withOpacity(0.6), AppColors.green.withOpacity(0.6)]
                : [AppColors.forest, AppColors.green],
            begin: Alignment.centerLeft,
            end:   Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color:      AppColors.green.withOpacity(0.35),
                    blurRadius: 20,
                    offset:     const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width:  22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.lightGrey,
                  ),
                )
              : Text(
                  'Create Account',
                  style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey),
                ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.darkBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.darkText3),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.darkBorder)),
      ],
    );
  }

  Widget _loginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText2),
        ),
        GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, RouteNames.login),
          child: Text(
            'Sign In',
            style: AppTextStyles.bodySmall.copyWith(
              color:           AppColors.sage,
              fontWeight:      FontWeight.w700,
              decoration:      TextDecoration.underline,
              decorationColor: AppColors.sage,
            ),
          ),
        ),
      ],
    );
  }

  Widget _eyeButton({required bool isObscure, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Icon(
          isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.darkText3,
          size:  20,
        ),
      ),
    );
  }

  InputDecoration _buildDecoration({
    required String   label,
    required String   hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText:          label,
      labelStyle:         AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3),
      floatingLabelStyle: AppTextStyles.labelMedium.copyWith(color: AppColors.green, fontSize: 18),
      hintText:  hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkText3.withOpacity(0.5)),
      filled:    true,
      fillColor: AppColors.darkBg1,
      prefixIcon: Icon(icon, color: AppColors.darkText3, size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.red, width: 1.5),
      ),
      errorStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.salmon),
    );
  }
}
