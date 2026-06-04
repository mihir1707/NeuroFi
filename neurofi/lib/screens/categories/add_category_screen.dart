import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final String _color = '#FFFFFF';

  static const _emojis = [
    '🍔','🚗','🛍️','🎬','💊','📚','📄','💼','📈','✈️','🛒','🏠',
    '💡','🎮','☕','🏋️','💅','🐾','🎁','📱','🏦','💰','🎯','🏖️',
    '🎓','🍕','🚇','⚡','🎵','🎨','🏥','🌿','🌊','🔧','💻','🎪',
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('New Category',
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
                  Center(
                    child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0x33FFFFFF), width: 2),
                      ),
                      child: Center(child: Text(_icon, style: const TextStyle(fontSize: 32))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: AppTextStyles.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.4)),
                      filled: true, fillColor: const Color(0xFF111111),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x33FFFFFF))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0x33FFFFFF))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Type', style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.6))),
                  const SizedBox(height: 8),
                  Row(
                    children: ['income','expense','both'].map((t) {
                      final sel   = t == _type;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _type = t),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: sel ? Colors.white.withValues(alpha: 0.1) : const Color(0xFF111111),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: sel ? Colors.white : const Color(0x33FFFFFF)),
                            ),
                            child: Center(child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              style: AppTextStyles.labelSmall.copyWith(
                                  color: sel ? Colors.white : Colors.white.withValues(alpha: 0.5)),
                            )),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Text('Icon', style: AppTextStyles.labelMedium.copyWith(color: Colors.white.withValues(alpha: 0.6))),
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
                            color: selected ? Colors.white.withValues(alpha: 0.15) : const Color(0xFF111111),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: selected ? Colors.white : const Color(0x33FFFFFF)),
                          ),
                          child: Center(child: Text(_emojis[i],
                              style: const TextStyle(fontSize: 20))),
                        ),
                      );
                    },
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
                child: Center(
                  child: isLoading
                      ? const SizedBox(width: 22, height: 22,
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : Text('Create Category',
                          style: AppTextStyles.buttonText.copyWith(color: Colors.black)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
