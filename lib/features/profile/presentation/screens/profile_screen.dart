import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../body_metrics/presentation/providers/body_metrics_provider.dart';
import '../../../../shared/widgets/app_header.dart';
import '../../../../shared/widgets/loading_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _targetWeightController;
  late TextEditingController _weeklyGoalController;
  bool _isEditing = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _targetWeightController = TextEditingController();
    _weeklyGoalController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    _weeklyGoalController.dispose();
    super.dispose();
  }

  void _initControllers(profile, double? latestWeight) {
    if (!_initialized) {
      _nameController.text = profile.name;
      _heightController.text = profile.height.toString();
      _weightController.text =
          latestWeight != null ? latestWeight.toString() : '0.0';
      _targetWeightController.text = profile.targetWeight.toString();
      _weeklyGoalController.text = profile.weeklyGoal.toString();
      _initialized = true;
    }
  }

  Future<void> _saveProfile(profile) async {
    final name = _nameController.text.trim();
    final height = double.tryParse(_heightController.text) ?? profile.height;
    final weight = double.tryParse(_weightController.text);
    final targetWeight =
        double.tryParse(_targetWeightController.text) ?? profile.targetWeight;
    final weeklyGoal =
        int.tryParse(_weeklyGoalController.text) ?? profile.weeklyGoal;

    final updatedProfile = profile.copyWith(
      name: name.isEmpty ? profile.name : name,
      height: height,
      targetWeight: targetWeight,
      weeklyGoal: weeklyGoal,
    );

    await ref.read(profileProvider.notifier).updateProfile(updatedProfile);

    if (weight != null) {
      ref.read(bodyMetricsProvider.notifier).addMetric(
            date: DateTime.now(),
            weightKg: weight,
          );
    }

    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final metricsAsync = ref.watch(bodyMetricsProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: profileAsync.when(
          loading: () => const LoadingWidget(),
          error: (err, stack) => Center(
              child: Text('Error: $err',
                  style: const TextStyle(color: Colors.red))),
          data: (profile) {
            if (profile == null) {
              return const Center(
                  child: Text('Profile not found',
                      style: TextStyle(color: AppColors.textPrimary)));
            }

            double? latestWeight;
            metricsAsync.whenData((metrics) {
              final withWeight =
                  metrics.where((m) => m.weightKg != null).toList();
              if (withWeight.isNotEmpty) {
                withWeight.sort((a, b) => b.date.compareTo(a.date));
                latestWeight = withWeight.first.weightKg;
              }
            });

            _initControllers(profile, latestWeight);

            return Column(
              children: [
                AppHeader(
                  title: 'Profile',
                  subtitle: 'YOUR DETAILS',
                  actions: [
                    IconButton(
                      icon: Icon(
                        _isEditing ? Icons.check : Icons.edit,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        if (_isEditing) {
                          _saveProfile(profile);
                        } else {
                          setState(() {
                            _isEditing = true;
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildProfileField(
                          'Name', _nameController, TextInputType.name),
                      const SizedBox(height: 16),
                      _buildProfileField('Height (cm)', _heightController,
                          TextInputType.number),
                      const SizedBox(height: 16),
                      _buildProfileField(
                          'Current Weight (kg)',
                          _weightController,
                          const TextInputType.numberWithOptions(decimal: true)),
                      const SizedBox(height: 16),
                      _buildProfileField(
                          'Target Weight (kg)',
                          _targetWeightController,
                          const TextInputType.numberWithOptions(decimal: true)),
                      const SizedBox(height: 16),
                      _buildProfileField('Weekly Gym Goal (Days)',
                          _weeklyGoalController, TextInputType.number),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileField(String label, TextEditingController controller,
      TextInputType keyboardType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: _isEditing,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardDark,
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
