import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('About FitTrack',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.fitness_center,
                    color: Colors.black, size: 48),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'FitTrack',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Track your gains. Own your progress.',
                style: TextStyle(color: AppColors.textHint, fontSize: 14),
              ),
            ),
            const SizedBox(height: 32),
            _Section(
              title: 'About This App',
              content:
                  'FitTrack is a no-nonsense, offline-first gym tracking app designed for people who are serious about their fitness journey. '
                  'Track workouts, measure progress, manage splits, log body metrics, and receive daily aggressive-friendly motivation — all stored locally on your device. '
                  'No subscriptions. No cloud. No excuses.',
            ),
            const SizedBox(height: 24),
            _InfoCard(children: [
              _InfoRow(
                icon: Icons.person,
                label: 'Developer',
                value: 'Nibin Joseph',
              ),
              const Divider(color: AppColors.borderDark),
              _InfoRow(
                icon: Icons.email_outlined,
                label: 'Contact',
                value: 'nibin.joseph.career@gmail.com',
              ),
              const Divider(color: AppColors.borderDark),
              _InfoRow(
                icon: Icons.info_outline,
                label: 'Version',
                value: '2.0.0',
              ),
              const Divider(color: AppColors.borderDark),
              _InfoRow(
                icon: Icons.storage_outlined,
                label: 'Storage',
                value: 'Local only (Hive)',
              ),
              const Divider(color: AppColors.borderDark),
              _InfoRow(
                icon: Icons.wifi_off,
                label: 'Internet',
                value: 'Not required',
              ),
            ]),
            const SizedBox(height: 24),
            _Section(
              title: 'Features',
              content: '• Workout logging with set tracking\n'
                  '• Custom exercise creation with photos\n'
                  '• Workout split management\n'
                  '• Body metrics & weight tracking\n'
                  '• Progress analytics & charts\n'
                  '• Rest timer with custom durations\n'
                  '• 300 daily motivational quotes\n'
                  '• Onboarding with personality setup\n'
                  '• Attendance tracking\n'
                  '• Fully offline — zero data leaves your phone',
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Designed & Developed by Nibin Joseph\nBuilt with Flutter & Hive',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
        const SizedBox(height: 10),
        Text(content,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14, height: 1.7)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textHint, size: 18),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(color: AppColors.textSecondary))),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ],
      ),
    );
  }
}
