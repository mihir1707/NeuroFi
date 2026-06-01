import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AddGroupScreen extends StatefulWidget {
  const AddGroupScreen({super.key});
  @override
  State<AddGroupScreen> createState() => _AddGroupScreenState();
}

class _AddGroupScreenState extends State<AddGroupScreen> {
  final _nameController  = TextEditingController();
  final _emailController = TextEditingController();
  String _icon = '👥';
  final _members = <String>[];

  static const _emojis = ['👥','🏠','✈️','🍕','🎮','🏖️','💼','🎓'];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _addMember() {
    final e = _emailController.text.trim();
    if (e.isNotEmpty && !_members.contains(e)) {
      setState(() { _members.add(e); _emailController.clear(); });
    }
  }

  InputDecoration get _dec => InputDecoration(
    filled: true, fillColor: AppColors.darkBg1,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
    labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0, elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Group', style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
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
                  Center(
                    child: Text(_icon, style: const TextStyle(fontSize: 52)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _emojis.map((e) {
                      final sel = e == _icon;
                      return GestureDetector(
                        onTap: () => setState(() => _icon = e),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: sel ? AppColors.forest : AppColors.darkBg1,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: sel ? AppColors.green : AppColors.darkBorder),
                          ),
                          child: Text(e, style: const TextStyle(fontSize: 18)),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: _dec.copyWith(labelText: 'Group Name'),
                  ),
                  const SizedBox(height: 20),
                  Text('Add Members', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _emailController,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                        decoration: _dec.copyWith(labelText: 'Member email'),
                        onSubmitted: (_) => _addMember(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _addMember,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_rounded, color: AppColors.lightGrey, size: 20),
                      ),
                    ),
                  ]),
                  if (_members.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 6,
                      children: _members.map((m) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.forest.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.forest.withOpacity(0.4)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(m, style: AppTextStyles.labelSmall.copyWith(color: AppColors.sage)),
                          const SizedBox(width: 6),
                          GestureDetector(
                            onTap: () => setState(() => _members.remove(m)),
                            child: const Icon(Icons.close_rounded, color: AppColors.sage, size: 14),
                          ),
                        ]),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: double.infinity, height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: Text('Create Group',
                    style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey))),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
