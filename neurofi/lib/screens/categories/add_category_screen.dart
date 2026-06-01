import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/category_provider.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key});
  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _nameController = TextEditingController();
  String _type  = 'expense';
  String _icon  = '📦';
  String _color = '#9DC08B';

  static const _emojis = [
    '🍔','🚗','🛍️','🎬','💊','📚','📄','💼','📈','✈️','🛒','🏠',
    '💡','🎮','☕','🏋️','💅','🐾','🎁','📱','🏦','💰','🎯','🏖️',
    '🎓','🍕','🚇','⚡','🎵','🎨','🏥','🌿','🌊','🔧','💻','🎪',
  ];

  static const _colors = [
    '#9DC08B', '#306D29', '#FFC94D', '#F38181',
    '#E89F71', '#F875AA', '#DA0037', '#40513B',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty) return;
    final ok = await context.read<CategoryProvider>().createCategory(
      name:  _nameController.text.trim(),
      type:  _type,
      icon:  _icon,
      color: _color,
    );
    if (ok && mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<CategoryProvider>().isLoading;
    final previewColor = _parseColor(_color);

    return Scaffold(
      backgroundColor: AppColors.darkBg0,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg0,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.lightGrey, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Category',
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.lightGrey)),
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
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: previewColor.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: previewColor.withOpacity(0.5), width: 2),
                      ),
                      child: Center(child: Text(_icon, style: const TextStyle(fontSize: 32))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.lightGrey),
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.darkText3),
                      filled: true, fillColor: AppColors.darkBg1,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.darkBorder)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.darkBorder)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.green, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Type', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['income','expense','both'].map((t) {
                      final sel   = t == _type;
                      final color = t == 'income' ? AppColors.green
                          : t == 'expense' ? AppColors.red : AppColors.amber;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? color.withOpacity(0.15) : AppColors.darkBg1,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: sel ? color : AppColors.darkBorder),
                            ),
                            child: Center(child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: sel ? color : AppColors.darkText2),
                            )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Icon', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
                  const SizedBox(height: 8),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6, crossAxisSpacing: 8, mainAxisSpacing: 8),
                    itemCount: _emojis.length,
                    itemBuilder: (_, i) {
                      final selected = _emojis[i] == _icon;
                      return GestureDetector(
                        onTap: () => setState(() => _icon = _emojis[i]),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected ? AppColors.forest.withOpacity(0.3) : AppColors.darkBg1,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: selected ? AppColors.green : AppColors.darkBorder),
                          ),
                          child: Center(child: Text(_emojis[i],
                              style: const TextStyle(fontSize: 20))),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text('Color', style: AppTextStyles.labelMedium.copyWith(color: AppColors.darkText3)),
                  const SizedBox(height: 8),
                  Row(
                    children: _colors.map((c) {
                      final color    = _parseColor(c);
                      final selected = c == _color;
                      return GestureDetector(
                        onTap: () => setState(() => _color = c),
                        child: Container(
                          margin: const EdgeInsets.only(right: 10),
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected ? AppColors.lightGrey : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: selected ? const Icon(Icons.check_rounded,
                              color: Colors.white, size: 18) : null,
                        ),
                      );
                    }).toList(),
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
                  gradient: const LinearGradient(colors: [AppColors.forest, AppColors.green]),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: AppColors.lightGrey, strokeWidth: 2))
                      : Text('Create Category',
                          style: AppTextStyles.buttonText.copyWith(color: AppColors.lightGrey)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
    } catch (_) {
      return AppColors.sage;
    }
  }
}
