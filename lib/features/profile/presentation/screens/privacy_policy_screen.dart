import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Privacy Policy',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.primary, size: 44),
            const SizedBox(height: 16),
            const Text(
              'Your Privacy, Guaranteed.',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: March 2026',
              style: TextStyle(color: AppColors.textHint, fontSize: 12),
            ),
            const SizedBox(height: 28),
            ..._sections.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.$1,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s.$2,
                        style: const TextStyle(
                            color: AppColors.textSecondary,
                            height: 1.7,
                            fontSize: 14),
                      ),
                    ],
                  ),
                )),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user, color: AppColors.primary),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'FitTrack collects zero data. Nothing leaves your device. Ever.',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Center(
              child: Text(
                'Questions? nibin.joseph.career@gmail.com',
                style: TextStyle(color: AppColors.textHint, fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  static const List<(String, String)> _sections = [
    (
      '1. Data Collection',
      'FitTrack does not collect any personal data. All information you enter — including your name, weight, workout logs, and progress — is stored exclusively on your device using local storage (Hive database). No data is transmitted to any server, third party, or cloud service.',
    ),
    (
      '2. Internet Access',
      'FitTrack requires zero internet access to function. The app operates entirely offline. No network requests are made at any time during the use of this application.',
    ),
    (
      '3. Data Storage',
      'Your data is stored locally using Hive, a lightweight local database on your Android or iOS device. You can delete all data at any time by uninstalling the app or clearing app data from your device settings.',
    ),
    (
      '4. Photos & Media',
      'If you choose to attach photos to your workouts or custom exercises, those images are stored in your device\'s local app storage directory. They are never uploaded or shared.',
    ),
    (
      '5. Analytics & Tracking',
      'FitTrack does not include any analytics SDKs, telemetry, crash reporting tools, or tracking libraries. Your usage patterns and behaviors are completely private.',
    ),
    (
      '6. Third Parties',
      'FitTrack does not share your data with any third party for any purpose, including advertising, analytics, or data brokering. There are no third-party integrations.',
    ),
    (
      '7. Permissions',
      'The app may request access to your device\'s photo gallery or camera solely for the purpose of attaching images to workout sessions or exercises. This access is optional and not required for core functionality.',
    ),
    (
      '8. Changes to This Policy',
      'If this policy is updated, changes will be reflected in the app. Since no personal data is collected, no notifications or special actions will be required from you.',
    ),
  ];
}
