import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../body_metrics/presentation/providers/body_metrics_provider.dart';
import '../../../../shared/widgets/app_header.dart';
import 'package:hive/hive.dart';
import '../../../../core/constants/hive_boxes.dart';
import '../../../../shared/widgets/loading_widget.dart';

import '../../../workout/data/models/workout_log_model.dart';
import '../../../exercise/data/models/exercise_model.dart';
import '../../../body_metrics/data/models/body_metric_model.dart';
import '../../../workout/data/models/workout_split_model.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../data/models/profile_model.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isStandalone;
  const ProfileScreen({super.key, this.isStandalone = true});

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
          profile.currentWeight > 0 ? profile.currentWeight.toString() : (latestWeight?.toString() ?? '0.0');
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
      currentWeight: weight ?? profile.currentWeight,
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

  Future<void> _confirmReset(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Reset Everything?',
            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
        content: const Text(
            'This will permanently delete all your workouts, custom exercises, attendance, profile, and progress data. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Hive.box<ProfileModel>(HiveBoxes.profile).clear();
        await Hive.box<ExerciseModel>(HiveBoxes.exercises).clear();
        await Hive.box<WorkoutLogModel>(HiveBoxes.workoutLogs).clear();
        await Hive.box<BodyMetricModel>(HiveBoxes.bodyMetrics).clear();
        await Hive.box<AttendanceModel>(HiveBoxes.attendance).clear();
        await Hive.box<WorkoutSplitModel>(HiveBoxes.workoutSplits).clear();
        
        await Future.delayed(const Duration(milliseconds: 100));

        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.splash,
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing data: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final metricsAsync = ref.watch(bodyMetricsProvider);

    return Scaffold(
      backgroundColor: widget.isStandalone ? AppColors.backgroundDark : Colors.transparent,
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
                            setState(() => _isEditing = true);
                          }
                        },
                      ),
                    if (widget.isStandalone)
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
                      const SizedBox(height: 32),
                      _SectionHeader(title: 'APP'),
                      const SizedBox(height: 8),
                      _NavTile(
                        icon: Icons.local_fire_department,
                        title: 'Daily Motivation',
                        subtitle: '300 aggressive gym quotes',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.dailyMotivation),
                      ),
                      _NavTile(
                        icon: Icons.info_outline,
                        title: 'About FitTrack',
                        subtitle: 'Developer, version, features',
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.aboutApp),
                      ),
                      _NavTile(
                        icon: Icons.lock_outline,
                        title: 'Privacy Policy',
                        subtitle: 'All data stays on your device',
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.privacyPolicy),
                      ),
                      const SizedBox(height: 32),
                      const _SectionHeader(title: 'DANGER ZONE'),
                      const SizedBox(height: 8),
                      _NavTile(
                        icon: Icons.delete_forever,
                        title: 'Erase All Data',
                        subtitle: 'Reset app and delete everything',
                        iconColor: AppColors.error,
                        textColor: AppColors.error,
                        onTap: () => _confirmReset(context),
                      ),
                      const SizedBox(height: 32),
                      const Center(
                        child: Text(
                          'Designed & Developed by Nibin Joseph\nnibin.joseph.career@gmail.com',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.textHint, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 24),
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

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
          color: AppColors.textHint,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5),
    );
  }
}

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: (iconColor ?? AppColors.primary), size: 20),
        ),
        title: Text(title,
            style: TextStyle(
                color: textColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        subtitle: Text(subtitle,
            style:
                const TextStyle(color: AppColors.textHint, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right,
            color: AppColors.textHint, size: 20),
        onTap: onTap,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      ),
    );
  }
}
