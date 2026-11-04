import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/constants.dart';
import '../core/formatters.dart';
import '../core/snackbar.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';

class AddEditTransactionScreen extends StatefulWidget {
  const AddEditTransactionScreen({super.key, this.transaction});

  /// null = add mode. Not null = edit mode with prefilled values.
  final TransactionModel? transaction;

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  String? _category;
  String? _type;
  DateTime _date = DateTime.now();

  String? _categoryError;
  String? _typeError;
  bool _isSaving = false;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.transaction;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _amountController = TextEditingController(
      text: existing == null ? '' : _plainAmount(existing.amount),
    );
    _category = existing?.category;
    _type = existing?.type;
    _date = existing?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _plainAmount(double value) {
    return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Select transaction date',
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final formIsValid = _formKey.currentState!.validate();
    setState(() {
      _categoryError = _category == null ? 'Please select a category' : null;
      _typeError = _type == null ? 'Please select a transaction type' : null;
    });
    if (!formIsValid || _category == null || _type == null) return;

    setState(() => _isSaving = true);

    final provider = context.read<TransactionProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final transaction = TransactionModel(
      id: widget.transaction?.id,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text.trim()),
      category: _category!,
      type: _type!,
      date: _date,
    );

    try {
      if (_isEditing) {
        await provider.updateTransaction(transaction);
      } else {
        await provider.addTransaction(transaction);
      }
      navigator.pop();
      showAppSnackBar(
        messenger,
        _isEditing ? 'Transaction updated' : 'Transaction added',
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showAppSnackBar(
        messenger,
        'Could not save the transaction. Please try again.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor =
        _type == TransactionType.expense ? AppColors.expense : AppColors.income;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FieldLabel('Title'),
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  decoration: fieldDecoration(
                    hint: 'e.g. Grocery shopping',
                    icon: Icons.edit_note_rounded,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Title cannot be empty';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Amount'),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                    LengthLimitingTextInputFormatter(12),
                  ],
                  decoration: fieldDecoration(
                    hint: '0.00',
                    icon: Icons.payments_outlined,
                    prefixText: '$kCurrencySymbol ',
                  ),
                  validator: (value) {
                    final text = (value ?? '').trim();
                    if (text.isEmpty) return 'Amount is required';
                    final amount = double.tryParse(text);
                    if (amount == null || amount <= 0) {
                      return 'Enter a valid amount greater than 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Category'),
                InputDecorator(
                  decoration: fieldDecoration(icon: Icons.category_rounded)
                      .copyWith(errorText: _categoryError),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _category,
                      isExpanded: true,
                      isDense: true,
                      hint: const Text('Select a category'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      borderRadius: BorderRadius.circular(14),
                      items: kCategories
                          .map(
                            (category) => DropdownMenuItem<String>(
                              value: category,
                              child: Row(
                                children: [
                                  Icon(
                                    categoryIcon(category),
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(category),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _category = value;
                          _categoryError = null;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const _FieldLabel('Transaction type'),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<String>(
                    emptySelectionAllowed: true,
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment<String>(
                        value: TransactionType.income,
                        label: Text('Income'),
                        icon: Icon(Icons.south_west_rounded, size: 18),
                      ),
                      ButtonSegment<String>(
                        value: TransactionType.expense,
                        label: Text('Expense'),
                        icon: Icon(Icons.north_east_rounded, size: 18),
                      ),
                    ],
                    selected: _type == null ? <String>{} : {_type!},
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) return;
                      setState(() {
                        _type = selection.first;
                        _typeError = null;
                      });
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.white,
                      selectedBackgroundColor: typeColor.withAlpha(30),
                      selectedForegroundColor: typeColor,
                      foregroundColor: AppColors.textSecondary,
                      side: BorderSide(
                        color: _typeError == null
                            ? AppColors.border
                            : AppColors.expense,
                      ),
                    ),
                  ),
                ),
                if (_typeError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 14),
                    child: Text(
                      _typeError!,
                      style: const TextStyle(
                        color: AppColors.expense,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 18),
                const _FieldLabel('Date'),
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: fieldDecoration(
                      icon: Icons.calendar_today_rounded,
                    ).copyWith(
                      suffixIcon:
                          const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                    child: Text(
                      Fmt.fullDate(_date),
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _isEditing ? 'Update Transaction' : 'Save Transaction',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}