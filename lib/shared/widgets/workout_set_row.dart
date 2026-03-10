import 'package:flutter/material.dart';
import '../../features/workout/domain/entities/workout_entities.dart';

class WorkoutSetRow extends StatelessWidget {
  final int setNumber;
  final WorkoutSetEntity setEntity;
  final ValueChanged<WorkoutSetEntity> onChanged;

  const WorkoutSetRow({
    super.key,
    required this.setNumber,
    required this.setEntity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '$setNumber',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildTextField(
              label: 'Target',
              value: setEntity.targetReps.toString(),
              onChanged: (val) {
                final reps = int.tryParse(val) ?? setEntity.targetReps;
                onChanged(setEntity.copyWith(targetReps: reps));
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildTextField(
              label: 'Actual',
              value: setEntity.completedReps.toString(),
              onChanged: (val) {
                final reps = int.tryParse(val) ?? setEntity.completedReps;
                onChanged(setEntity.copyWith(completedReps: reps));
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildTextField(
              label: 'Weight',
              value: setEntity.weight.toString(),
              isDecimal: true,
              onChanged: (val) {
                final weight = double.tryParse(val) ?? setEntity.weight;
                onChanged(setEntity.copyWith(weight: weight));
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _buildTextField(
              label: 'RPE',
              value: setEntity.rpe?.toString() ?? '',
              onChanged: (val) {
                final rpe = int.tryParse(val);
                onChanged(setEntity.copyWith(rpe: rpe));
              },
            ),
          ),
          const SizedBox(width: 8),
          Checkbox(
            value: setEntity.isCompleted,
            onChanged: (val) {
              onChanged(setEntity.copyWith(isCompleted: val ?? false));
            },
            activeColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    bool isDecimal = false,
  }) {
    return TextFormField(
      initialValue: value,
      keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 10),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onChanged: onChanged,
    );
  }
}
