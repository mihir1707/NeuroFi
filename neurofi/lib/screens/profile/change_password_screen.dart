import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController     = TextEditingController();
  final _confirmController = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _isLoading   = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // ── Password strength ──────────────────────────────────────────────
  String get _strength {
    final p = _newController.text;
    if (p.length < 6) return 'Weak';
    if (p.length < 10 && !RegExp(r'[A-Z]').hasMatch(p)) return 'Medium';
    if (p.length >= 10 &&
        RegExp(r'[A-Z]').hasMatch(p) &&
        RegExp(r'[0-9]').hasMatch(p)) {
      return 'Strong';
    }
    return 'Medium';
  }

  Color get _strengthColor {
    switch (_strength) {
      case 'Strong': return AppColors.green;
      case 'Medium': return AppColors.amber;
      default:       return AppColors.red;
    }
  }

  double get _strengthValue {
    switch (_strength) {
      case 'Strong': return 1.0;
      case 'Medium': return 0.6;
      default:       return 0.25;
    }
  }

  // ── Submit ─────────────────────────────────────────────────────────
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context);
    }
  }

  // ── Input decoration (login-style) ─────────────────────────────────
  InputDecoration _buildDecoration({
    required String label,
    required String hint,
    required bool show,
    required VoidCallback onToggle,
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
      prefixIcon: const Icon(
        Icons.lock_outline_rounded,
        color: Color.fromARGB(255, 209, 205, 205),
        size: 20,
      ),
      suffixIcon: GestureDetector(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            show ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: const Color.fromARGB(255, 209, 205, 205),
            size: 20,
          ),
        ),
      ),
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
      errorStyle: AppTextStyles.labelSmall.copyWith(
        color: const Color.fromARGB(255, 223, 193, 193),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: Colors.white,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Password',
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
              const SizedBox(height: 16),

              // ── Current Password ──
              TextFormField(
                controller: _currentController,
                obscureText: !_showCurrent,
                textInputAction: TextInputAction.next,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color.fromRGBO(245, 247, 250, 1),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Current password is required';
                  return null;
                },
                decoration: _buildDecoration(
                  label: 'Current Password',
                  hint: 'Enter current password',
                  show: _showCurrent,
                  onToggle: () => setState(() => _showCurrent = !_showCurrent),
                ),
              ),

              const SizedBox(height: 16),

              // ── New Password ──
              TextFormField(
                controller: _newController,
                obscureText: !_showNew,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color.fromRGBO(245, 247, 250, 1),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'New password is required';
                  if (v.length < 8) return 'Password must be at least 8 characters';
                  return null;
                },
                decoration: _buildDecoration(
                  label: 'New Password',
                  hint: 'Enter new password',
                  show: _showNew,
                  onToggle: () => setState(() => _showNew = !_showNew),
                ),
              ),

              // ── Strength bar ──
              if (_newController.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _strengthValue,
                          minHeight: 4,
                          backgroundColor: Colors.white12,
                          valueColor: AlwaysStoppedAnimation(_strengthColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _strength,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: _strengthColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 16),

              // ── Confirm Password ──
              TextFormField(
                controller: _confirmController,
                obscureText: !_showConfirm,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color.fromRGBO(245, 247, 250, 1),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please confirm your new password';
                  if (v != _newController.text) return 'Passwords do not match';
                  return null;
                },
                decoration: _buildDecoration(
                  label: 'Confirm New Password',
                  hint: 'Re-enter new password',
                  show: _showConfirm,
                  onToggle: () => setState(() => _showConfirm = !_showConfirm),
                ),
              ),

              const SizedBox(height: 36),

              // ── Submit button (login-style) ──
              GestureDetector(
                onTap: _isLoading ? null : _submit,
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
                            'Update Password',
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
            ],
          ),
        ),
      ),
    );
  }
}
