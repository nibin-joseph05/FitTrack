import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';


class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim =
        Tween<double>(begin: 0, end: 1).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _fadeController.reset();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
  }

  void _startProfileSetup() {
    Navigator.pushReplacementNamed(context, AppRoutes.profileSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (_) {},
            children: [
              _WelcomePage(onContinue: _nextPage),
              _PrivacyPage(onContinue: _startProfileSetup),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageShell extends StatelessWidget {
  final Widget child;
  const _PageShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: child,
    );
  }
}

class _WelcomePage extends StatelessWidget {
  final VoidCallback onContinue;
  const _WelcomePage({required this.onContinue});

  void _showQuitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderDark, width: 2),
        ),
        title: const Text(
          'Giving up already?',
          style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 22,
              letterSpacing: -0.5),
        ),
        content: const Text(
          'Sure, close the app. The couch is calling. Your comfort zone will always be there to keep you exactly where you are right now.\n\nEnjoy staying average.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 15, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16),
        actions: [
          TextButton(
            onPressed: () => SystemNavigator.pop(),
            child: const Text('YEAH, I\'M WEAK (EXIT)', style: TextStyle(color: AppColors.textHint, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('I\'M STAYING', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.asset(
                'assets/logo/logo.png',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.cardDark,
                  child: const Icon(Icons.fitness_center, color: AppColors.primary, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Welcome.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -2),
          ),
          const SizedBox(height: 16),
          const Text(
            'True results demand true pain.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'A great physique isn\'t handed out—it\'s forged through brutal, consistent hard work. '
            'This app will push you to your limits and hold you accountable.\n\n'
            'If you\'re looking for an easy way out, quit now. If you\'re ready to put in the work, step inside.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.7),
          ),
          const Spacer(flex: 2),
          _PrimaryButton(label: 'I\'M READY. LET\'S GO', onPressed: onContinue),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'By continuing, you accept our Privacy Policy.',
              style: TextStyle(fontSize: 12, color: AppColors.textHint),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => _showQuitDialog(context),
              child: const Text(
                'I\'m not ready (Exit)',
                style: TextStyle(color: AppColors.textHint, decoration: TextDecoration.underline),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PrivacyPage extends StatelessWidget {
  final VoidCallback onContinue;
  const _PrivacyPage({required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          const Icon(Icons.lock_outline, color: AppColors.primary, size: 48),
          const SizedBox(height: 24),
          const Text(
            'Your data stays with you.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 20),
          ...[
            ('No internet required', 'FitTrack works 100% offline.'),
            ('No data leaves your phone',
                'Every workout, weight entry, and personal detail lives only on this device.'),
            ('No accounts, no tracking',
                'We don\'t know who you are. We don\'t want to. Your privacy is absolute.'),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 28),
                  const SizedBox(height: 8),
                  Text(item.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(item.$2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary, height: 1.5)),
                ],
              ),
            ),
          ),
          const Spacer(flex: 2),
          _PrimaryButton(
              label: 'I UNDERSTAND, CONTINUE', onPressed: onContinue),
        ],
      ),
    );
  }
}


class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.5)),
      ),
    );
  }
}
