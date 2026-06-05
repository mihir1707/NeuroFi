import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/account_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/currency_formatter.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});
  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _nameController    = TextEditingController();
  final _balanceController = TextEditingController();
  final _institutionController = TextEditingController();
  final _last4Controller   = TextEditingController();
  String _type     = 'bank';
  String _icon     = '🏦';
  final String _currency = 'INR';
  final String _color    = '#40513B';

  static const _typeIcons = {
    'bank': '🏦', 'cash': '💵', 'credit_card': '💳',
    'debit_card': '💳', 'wallet': '👛', 'investment': '📈', 'loan': '🏧',
  };

  InputDecoration get _dec => InputDecoration(
    filled: true, fillColor: const Color(0xFF111111),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x33FFFFFF))),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x33FFFFFF))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white, width: 1.5)),
    labelStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.6)),
  );

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;
    final balance = double.tryParse(_balanceController.text) ?? 0;
    final currency = context.read<AuthProvider>().user?.currency ?? _currency;
    final ok = await context.read<AccountProvider>().createAccount(
      name:               _nameController.text.trim(),
      type:               _type,
      balance:            balance,
      currency:           currency,
      institution:        _institutionController.text.trim(),
      accountNumberLast4: _last4Controller.text.trim(),
      icon:               _icon,
      color:              _color,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    _institutionController.dispose();
    _last4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AccountProvider>().isLoading;
    final currency  = context.watch<AuthProvider>().user?.currency ?? 'INR';
    final sym       = CurrencyFormatter.symbolFor(currency);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Account',
            style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _typeIcons.entries.map((e) {
                        final sel = e.key == _type;
                        return GestureDetector(
                          onTap: () => setState(() { _type = e.key; _icon = e.value; }),
                          child: Container(
                            width: 44, height: 44,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: sel ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: sel ? Colors.white : const Color(0x33FFFFFF)),
                            ),
                            child: Center(child: Text(e.value, style: const TextStyle(fontSize: 20))),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    decoration: _dec.copyWith(labelText: 'Account Name'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _balanceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    decoration: _dec.copyWith(labelText: 'Initial Balance', prefixText: '$sym '),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _institutionController,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    decoration: _dec.copyWith(labelText: 'Bank / Institution (optional)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _last4Controller,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    decoration: _dec.copyWith(labelText: 'Last 4 digits (optional)', counterText: ''),
                  ),

                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: GestureDetector(
              onTap: isLoading ? null : _submit,
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: isLoading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                    : Text('Add Account',
                        style: AppTextStyles.buttonText.copyWith(color: Colors.black))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
