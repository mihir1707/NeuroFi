import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../providers/auth_provider.dart';
import '../../../router/route_names.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // print(_emailController.text);

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed. Please try again.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _emailField(),
          const SizedBox(height: 16),
          _passwordField(),
          const SizedBox(height: 10),
          _forgotPasswordRow(),
          const SizedBox(height: 28),
          _loginButton(isLoading),
          const SizedBox(height: 24),
          _divider(),
          const SizedBox(height: 20),
          _registerLink(),
        ],
      ),
    );
  }

  Widget _emailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
      validator: Validators.email,
      decoration: _buildDecoration(
        label: 'Email Address',
        hint: 'mihirkhunt45@gmail.com',
        icon: Icons.email_outlined,
      ),
    );
  }

  Widget _passwordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _submit(),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
      validator: Validators.password,
      decoration: _buildDecoration(
        label: 'Password',
        hint: 'Enter your password',
        icon: Icons.lock_outline_rounded,
        suffix: GestureDetector(
          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppColors.darkText3,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _forgotPasswordRow() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {},
        child: Text(
          'Forgot Password?',
          style: AppTextStyles.labelMedium.copyWith(color: AppColors.sage),
        ),
      ),
    );
  }

  Widget _loginButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _submit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [
                    AppColors.forest.withOpacity(0.6),
                    AppColors.green.withOpacity(0.6),
                  ]
                : [AppColors.forest, AppColors.green],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.green.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.lightGrey,
                  ),
                )
              : Text(
                  'Sign In',
                  style: AppTextStyles.buttonText.copyWith(
                    color: AppColors.lightGrey,
                  ),
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
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.darkText3,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.darkBorder)),
      ],
    );
  }

  Widget _registerLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText2),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.pushReplacementNamed(context, RouteNames.register),
          child: Text(
            'Sign Up',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.sage,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.sage,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _buildDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.darkText3,
      ),
      floatingLabelStyle: AppTextStyles.labelMedium.copyWith(
        color: AppColors.green,
        fontSize: 18,
      ),
      hintText: hint,
      hintStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.darkText3.withOpacity(0.5),
      ),
      filled: true,
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
