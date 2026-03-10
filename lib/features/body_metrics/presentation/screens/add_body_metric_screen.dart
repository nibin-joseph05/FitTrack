import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../providers/body_metrics_provider.dart';

class AddBodyMetricScreen extends ConsumerStatefulWidget {
  const AddBodyMetricScreen({super.key});

  @override
  ConsumerState<AddBodyMetricScreen> createState() =>
      _AddBodyMetricScreenState();
}

class _AddBodyMetricScreenState extends ConsumerState<AddBodyMetricScreen> {
  final _weightCtrl = TextEditingController();
  final _bodyFatCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _hipCtrl = TextEditingController();
  final _armCtrl = TextEditingController();
  final _thighCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _bodyFatCtrl.dispose();
    _chestCtrl.dispose();
    _waistCtrl.dispose();
    _hipCtrl.dispose();
    _armCtrl.dispose();
    _thighCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  bool _hasAnyValue() {
    return [
      _weightCtrl,
      _bodyFatCtrl,
      _chestCtrl,
      _waistCtrl,
      _hipCtrl,
      _armCtrl,
      _thighCtrl,
    ].any((c) => c.text.trim().isNotEmpty);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.primary,
            surface: AppColors.cardDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _save() async {
    if (!_hasAnyValue()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one measurement')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      await ref
          .read(bodyMetricsProvider.notifier)
          .addMetric(
            date: _selectedDate,
            weightKg: double.tryParse(_weightCtrl.text),
            bodyFatPercent: double.tryParse(_bodyFatCtrl.text),
            chestCm: double.tryParse(_chestCtrl.text),
            waistCm: double.tryParse(_waistCtrl.text),
            hipCm: double.tryParse(_hipCtrl.text),
            armCm: double.tryParse(_armCtrl.text),
            thighCm: double.tryParse(_thighCtrl.text),
            notes: _notesCtrl.text.trim().isEmpty
                ? null
                : _notesCtrl.text.trim(),
          );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Body Metrics'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _DatePicker(date: _selectedDate, onTap: _pickDate),
          const SizedBox(height: 24),
          _SectionLabel('Body Weight & Composition'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MetricInput(
                  controller: _weightCtrl,
                  label: 'Weight',
                  suffix: 'kg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricInput(
                  controller: _bodyFatCtrl,
                  label: 'Body Fat',
                  suffix: '%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel('Measurements (cm)'),
          const SizedBox(height: 12),
          _MeasurementGrid(
            entries: [
              ('Chest', _chestCtrl),
              ('Waist', _waistCtrl),
              ('Hip', _hipCtrl),
              ('Arm', _armCtrl),
              ('Thigh', _thighCtrl),
            ],
          ),
          const SizedBox(height: 24),
          _SectionLabel('Notes'),
          const SizedBox(height: 12),
          TextFormField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Optional notes...'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final DateTime date;
  final VoidCallback onTap;
  const _DatePicker({required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textHint,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _MetricInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String suffix;

  const _MetricInput({
    required this.controller,
    required this.label,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        suffixStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
      ),
    );
  }
}

class _MeasurementGrid extends StatelessWidget {
  final List<(String, TextEditingController)> entries;
  const _MeasurementGrid({required this.entries});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < entries.length; i += 2) {
      final hasNext = i + 1 < entries.length;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: _MetricInput(
                  controller: entries[i].$2,
                  label: entries[i].$1,
                  suffix: 'cm',
                ),
              ),
              if (hasNext) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricInput(
                    controller: entries[i + 1].$2,
                    label: entries[i + 1].$1,
                    suffix: 'cm',
                  ),
                ),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
