import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, RouteNames.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Login failed. Please try again.'),
          backgroundColor: const Color.fromRGBO(255, 90, 95, 1),
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
      style: AppTextStyles.bodyMedium.copyWith(color: const Color.fromRGBO(245, 247, 250, 1)),
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
      style: AppTextStyles.bodyMedium.copyWith(color: const Color.fromRGBO(245, 247, 250, 1)),
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
              color: const Color.fromARGB(255, 209, 205, 205),
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
          style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
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
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: isLoading
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
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color.fromRGBO(245, 247, 250, 1),
                  ),
                )
              : Text(
                  'Sign In',
                  style: AppTextStyles.buttonText.copyWith(
                    color: const Color.fromRGBO(245, 247, 250, 1),
                    decorationColor: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _divider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'or',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: Colors.white)),
      ],
    );
  }

  Widget _registerLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account? ",
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        GestureDetector(
          onTap: () =>
              Navigator.pushReplacementNamed(context, RouteNames.register),
          child: Text(
            'Sign Up',
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
              decorationColor: Colors.white,
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
      prefixIcon: Icon(icon, color: const Color.fromARGB(255, 209, 205, 205), size: 20),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color.fromARGB(255, 209, 205, 205)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color.fromARGB(255, 233, 226, 226)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color.fromARGB(255, 223, 193, 193)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      errorStyle: AppTextStyles.labelSmall.copyWith(color: Color.fromARGB(255, 223, 193, 193)),
    );
  }
}
