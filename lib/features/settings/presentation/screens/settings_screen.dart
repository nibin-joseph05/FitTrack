import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
            const Text(
              'Settings',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 28),
            _SettingsSection(
              title: 'App',
              items: [
                _SettingsTile(
                  icon: Icons.fitness_center,
                  title: 'Units',
                  subtitle: 'Kilograms (kg)',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Workout reminders',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.color_lens_outlined,
                  title: 'Theme',
                  subtitle: 'Dark mode',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'Data',
              items: [
                _SettingsTile(
                  icon: Icons.cloud_upload_outlined,
                  title: 'Export Data',
                  subtitle: 'Export as JSON',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.restore_outlined,
                  title: 'Reset Data',
                  subtitle: 'Clear all workout data',
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: AppColors.error,
                  ),
                  onTap: () => _showResetDialog(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SettingsSection(
              title: 'About',
              items: [
                _SettingsTile(
                  icon: Icons.info_outline,
                  title: 'Version',
                  subtitle: '1.0.0',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.code_outlined,
                  title: 'Built with Flutter',
                  subtitle: 'Clean Architecture + Riverpod + Hive',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.black,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'FitTrack',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Track your gains. Own your progress.',
                    style: TextStyle(fontSize: 12, color: AppColors.textHint),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all workouts, exercises, and body metrics. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Reset',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsTile> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textHint,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(
                children: [
                  e.value,
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 56,
                      color: AppColors.borderDark,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.primary),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textHint),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, size: 18, color: AppColors.textHint),
    );
  }
}
