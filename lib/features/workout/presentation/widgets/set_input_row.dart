import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/workout_entities.dart';

class SetInputRow extends StatefulWidget {
  final WorkoutSetEntity set;
  final ValueChanged<WorkoutSetEntity> onChanged;
  final VoidCallback onRemove;

  const SetInputRow({
    super.key,
    required this.set,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<SetInputRow> createState() => _SetInputRowState();
}

class _SetInputRowState extends State<SetInputRow> {
  late final TextEditingController _repsController;
  late final TextEditingController _weightController;

  @override
  void initState() {
    super.initState();
    _repsController = TextEditingController(text: widget.set.reps.toString());
    _weightController = TextEditingController(
      text: widget.set.weight.toString(),
    );
  }

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _emit() {
    final reps = int.tryParse(_repsController.text) ?? widget.set.reps;
    final weight = double.tryParse(_weightController.text) ?? widget.set.weight;
    widget.onChanged(widget.set.copyWith(reps: reps, weight: weight));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${widget.set.setNumber}',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textHint,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: _InputField(
              controller: _repsController,
              onChanged: (_) => _emit(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _InputField(
              controller: _weightController,
              onChanged: (_) => _emit(),
              allowDecimal: true,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: widget.onRemove,
            child: const Icon(
              Icons.remove_circle_outline,
              size: 20,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool allowDecimal;

  const _InputField({
    required this.controller,
    required this.onChanged,
    this.allowDecimal = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: allowDecimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.number,
      inputFormatters: [
        allowDecimal
            ? FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
            : FilteringTextInputFormatter.digitsOnly,
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
