import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController     = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showCurrent = false, _showNew = false, _showConfirm = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String get _strength {
    final p = _newController.text;
    if (p.length < 6) return 'Weak';
    if (p.length < 10 && !RegExp(r'[A-Z]').hasMatch(p)) return 'Medium';
    if (p.length >= 10 && RegExp(r'[A-Z]').hasMatch(p) && RegExp(r'[0-9]').hasMatch(p)) return 'Strong';
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

  Future<void> _submit() async {
    if (_newController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')));
      return;
    }
    if (_newController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')));
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully'),
          backgroundColor: AppColors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  InputDecoration _dec(String label, bool show, VoidCallback toggle) => InputDecoration(
    filled: true,
    fillColor: AppColors.darkBg1,
    labelText: label,
    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.darkText3, size: 18),
    suffixIcon: GestureDetector(
      onTap: toggle,
      child: Icon(show ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.darkText3, size: 18),
    ),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Change Password',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _currentController,
              obscureText: !_showCurrent,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
              decoration: _dec('Current Password', _showCurrent,
                  () => setState(() => _showCurrent = !_showCurrent)),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _newController,
              obscureText: !_showNew,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
              decoration: _dec('New Password', _showNew,
                  () => setState(() => _showNew = !_showNew)),
            ),
            if (_newController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _strengthValue,
                        minHeight: 4,
                        backgroundColor: AppColors.darkBg2,
                        valueColor: AlwaysStoppedAnimation(_strengthColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(_strength, style: AppTextStyles.labelSmall.copyWith(color: _strengthColor)),
                ],
              ),
            ],
            const SizedBox(height: 14),
            TextField(
              controller: _confirmController,
              obscureText: !_showConfirm,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
              decoration: _dec('Confirm New Password', _showConfirm,
                  () => setState(() => _showConfirm = !_showConfirm)),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _isLoading ? null : _submit,
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: AppColors.lightGrey, strokeWidth: 2))
                      : Text('Update Password',
                          style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
