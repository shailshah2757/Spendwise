import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/constants/app_strings.dart';
import '../providers/category_provider.dart';

// Curated list of category icons
const _availableIcons = <_IconOption>[
  _IconOption(Icons.restaurant, 'Food'),
  _IconOption(Icons.local_cafe, 'Coffee'),
  _IconOption(Icons.shopping_bag, 'Shopping'),
  _IconOption(Icons.directions_car, 'Transport'),
  _IconOption(Icons.home, 'Home'),
  _IconOption(Icons.bolt, 'Utilities'),
  _IconOption(Icons.local_hospital, 'Health'),
  _IconOption(Icons.school, 'Education'),
  _IconOption(Icons.movie, 'Entertainment'),
  _IconOption(Icons.flight, 'Travel'),
  _IconOption(Icons.sports_esports, 'Gaming'),
  _IconOption(Icons.fitness_center, 'Fitness'),
  _IconOption(Icons.pets, 'Pets'),
  _IconOption(Icons.child_care, 'Kids'),
  _IconOption(Icons.card_giftcard, 'Gifts'),
  _IconOption(Icons.phone_android, 'Phone'),
  _IconOption(Icons.wifi, 'Internet'),
  _IconOption(Icons.subscriptions, 'Subscriptions'),
  _IconOption(Icons.local_gas_station, 'Fuel'),
  _IconOption(Icons.local_parking, 'Parking'),
  _IconOption(Icons.checkroom, 'Clothing'),
  _IconOption(Icons.spa, 'Beauty'),
  _IconOption(Icons.build, 'Repairs'),
  _IconOption(Icons.savings, 'Savings'),
  _IconOption(Icons.receipt_long, 'Bills'),
  _IconOption(Icons.volunteer_activism, 'Charity'),
  _IconOption(Icons.music_note, 'Music'),
  _IconOption(Icons.book, 'Books'),
  _IconOption(Icons.local_grocery_store, 'Groceries'),
  _IconOption(Icons.label, 'Other'),
];

const _availableColors = <Color>[
  Color(0xFF26A69A), // teal
  Color(0xFF42A5F5), // blue
  Color(0xFFEF5350), // red
  Color(0xFFFFCA28), // amber
  Color(0xFF66BB6A), // green
  Color(0xFFAB47BC), // purple
  Color(0xFFFF7043), // deep orange
  Color(0xFF5C6BC0), // indigo
  Color(0xFF29B6F6), // light blue
  Color(0xFFEC407A), // pink
  Color(0xFF8D6E63), // brown
  Color(0xFF78909C), // blue grey
];

class _IconOption {
  final IconData icon;
  final String label;
  const _IconOption(this.icon, this.label);
}

class CategoryPage extends ConsumerWidget {
  const CategoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.categories)),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(child: Text(AppStrings.noCategories));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final cs = Theme.of(context).colorScheme;
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Slidable(
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  extentRatio: 0.25,
                  children: [
                    CustomSlidableAction(
                      onPressed: (_) {
                        ref
                            .read(categoryNotifierProvider.notifier)
                            .delete(cat.id);
                      },
                      backgroundColor: isDark
                          ? cs.error.withValues(alpha: 0.85)
                          : cs.errorContainer,
                      foregroundColor:
                          isDark ? cs.onError : cs.onErrorContainer,
                      borderRadius: BorderRadius.circular(16),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delete_outline, size: 22),
                          SizedBox(height: 4),
                          Text('Delete',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(cat.colorValue),
                      child: Icon(
                        IconData(cat.iconCodePoint,
                            fontFamily: 'MaterialIcons'),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(cat.name),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddCategorySheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddCategorySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddCategorySheet(
        onSave: (name, iconCodePoint, colorValue) {
          ref.read(categoryNotifierProvider.notifier).add(
                name,
                iconCodePoint,
                colorValue,
              );
          Navigator.of(ctx).pop();
        },
      ),
    );
  }
}

class _AddCategorySheet extends StatefulWidget {
  final void Function(String name, int iconCodePoint, int colorValue) onSave;

  const _AddCategorySheet({required this.onSave});

  @override
  State<_AddCategorySheet> createState() => _AddCategorySheetState();
}

class _AddCategorySheetState extends State<_AddCategorySheet> {
  final _nameController = TextEditingController();
  int _selectedIconIndex = 0;
  int _selectedColorIndex = 0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedIcon = _availableIcons[_selectedIconIndex];
    final selectedColor = _availableColors[_selectedColorIndex];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                AppStrings.addCategory,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 20),

              // Preview
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: selectedColor,
                      child: Icon(
                        selectedIcon.icon,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _nameController.text.isEmpty
                          ? 'Category Name'
                          : _nameController.text,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _nameController.text.isEmpty
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Name field
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: AppStrings.categoryName,
                  prefixIcon: Icon(Icons.edit_outlined,
                      size: 20, color: cs.onSurfaceVariant),
                ),
                textCapitalization: TextCapitalization.words,
                autofocus: true,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Icon picker label
              Text(
                'Choose Icon',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Icon grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final iconOpt = _availableIcons[index];
                  final isSelected = index == _selectedIconIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIconIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? selectedColor.withValues(alpha: 0.15)
                            : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected
                            ? Border.all(color: selectedColor, width: 2)
                            : null,
                      ),
                      child: Icon(
                        iconOpt.icon,
                        size: 22,
                        color: isSelected ? selectedColor : cs.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Color picker label
              Text(
                'Choose Color',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),

              // Color row
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(_availableColors.length, (index) {
                  final color = _availableColors[index];
                  final isSelected = index == _selectedColorIndex;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedColorIndex = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: cs.onSurface,
                                width: 3,
                              )
                            : null,
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _nameController.text.trim().isEmpty
                      ? null
                      : () {
                          widget.onSave(
                            _nameController.text.trim(),
                            selectedIcon.icon.codePoint,
                            selectedColor.toARGB32(),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    AppStrings.save,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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
