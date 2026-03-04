import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../category/presentation/providers/category_provider.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/entities/expense.dart';
import '../providers/expense_provider.dart';
import '../widgets/receipt_picker_widget.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String? _receiptPath;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final expense = Expense(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      categoryId: _selectedCategoryId!,
      date: _selectedDate,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      receiptPath: _receiptPath,
    );

    await ref.read(expenseNotifierProvider.notifier).add(expense);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final categoriesState = ref.watch(categoryNotifierProvider);
    final currencySymbol = ref.watch(currencySymbolProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.addExpense),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  // --- Amount Hero Section ---
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'How much?',
                      style: tt.bodyMedium?.copyWith(
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            currencySymbol,
                            style: tt.headlineMedium?.copyWith(
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 80, maxWidth: 280),
                            child: TextFormField(
                              controller: _amountCtrl,
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                height: 1.1,
                              ),
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(
                                  fontSize: 48,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade300,
                                  height: 1.1,
                                ),
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                filled: false,
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                                errorStyle: const TextStyle(fontSize: 12),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              textAlign: TextAlign.center,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                                LengthLimitingTextInputFormatter(12),
                              ],
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'Required';
                                final parsed = double.tryParse(v.trim());
                                if (parsed == null || parsed <= 0) return 'Invalid';
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // --- Form Fields Card ---
                  Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: AppColors.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          // Title
                          _FormRow(
                            icon: Icons.edit_outlined,
                            child: TextFormField(
                              controller: _titleCtrl,
                              decoration: _cardInputDecoration('Title'),
                              textCapitalization: TextCapitalization.sentences,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? AppStrings.fieldRequired : null,
                            ),
                          ),
                          const _CardDivider(),

                          // Category
                          _FormRow(
                            icon: Icons.category_outlined,
                            child: categoriesState.when(
                              loading: () => const Padding(
                                padding: EdgeInsets.symmetric(vertical: 14),
                                child: SizedBox(
                                  height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              error: (_, __) => const Text('Failed to load'),
                              data: (categories) => DropdownButtonFormField<String>(
                                initialValue: _selectedCategoryId,
                                decoration: _cardInputDecoration('Category'),
                                icon: Icon(Icons.keyboard_arrow_down_rounded,
                                    color: Colors.grey.shade400),
                                items: categories
                                    .map((c) => DropdownMenuItem(
                                          value: c.id,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: Color(c.colorValue),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(c.name),
                                            ],
                                          ),
                                        ))
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedCategoryId = v),
                                validator: (v) =>
                                    v == null ? AppStrings.fieldRequired : null,
                              ),
                            ),
                          ),
                          const _CardDivider(),

                          // Date
                          _FormRow(
                            icon: Icons.calendar_today_outlined,
                            child: GestureDetector(
                              onTap: _pickDate,
                              behavior: HitTestBehavior.opaque,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        DateFormat('EEE, dd MMM yyyy')
                                            .format(_selectedDate),
                                        style: tt.bodyLarge,
                                      ),
                                    ),
                                    Icon(Icons.chevron_right,
                                        size: 20, color: Colors.grey.shade400),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const _CardDivider(),

                          // Notes
                          _FormRow(
                            icon: Icons.notes_outlined,
                            child: TextFormField(
                              controller: _notesCtrl,
                              decoration: _cardInputDecoration('Notes (optional)'),
                              maxLines: 1,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // --- Receipt Attachment ---
                  ReceiptPickerWidget(
                    receiptPath: _receiptPath,
                    onReceiptPicked: (path) =>
                        setState(() => _receiptPath = path),
                  ),
                ],
              ),
            ),

            // --- Bottom Save Button ---
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22, height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Add Expense',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _cardInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontWeight: FontWeight.w400,
      ),
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      isDense: true,
      errorStyle: const TextStyle(fontSize: 11, height: 0.5),
    );
  }
}

class _FormRow extends StatelessWidget {
  final IconData icon;
  final Widget child;

  const _FormRow({required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade400),
          const SizedBox(width: 14),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        thickness: 0.5,
        color: AppColors.outlineVariant.withValues(alpha: 0.6),
      ),
    );
  }
}
