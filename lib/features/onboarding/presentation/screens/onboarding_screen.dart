import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();


  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _targetWeightController = TextEditingController();
  int _weeklyGoal = 4;

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
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
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

  Future<void> _finish() async {
    final name = _nameController.text.trim();
    final heightText = _heightController.text.trim();
    final weightText = _weightController.text.trim();
    final targetText = _targetWeightController.text.trim();

    if (name.isEmpty || heightText.isEmpty || weightText.isEmpty || targetText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all fields. No excuses.')),
      );
      return;
    }

    await ref.read(profileProvider.notifier).completeOnboarding(
          name: name,
          height: double.tryParse(heightText) ?? 170.0,
          currentWeight: double.tryParse(weightText) ?? 70.0,
          targetWeight: double.tryParse(targetText) ?? 70.0,
          weeklyGoal: _weeklyGoal,
        );

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
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
              _PrivacyPage(onContinue: _nextPage),
              _NamePage(controller: _nameController, onContinue: _nextPage),
              _ProfileSetupPage(
                heightController: _heightController,
                weightController: _weightController,
                targetWeightController: _targetWeightController,
                weeklyGoal: _weeklyGoal,
                onGoalChanged: (v) => setState(() => _weeklyGoal = v),
                onFinish: _finish,
              ),
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

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.accent]),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.fitness_center,
                color: Colors.black, size: 44),
          ),
          const SizedBox(height: 32),
          const Text(
            'FitTrack.',
            style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                letterSpacing: -2),
          ),
          const SizedBox(height: 16),
          const Text(
            'No soft boys allowed.',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text(
            'You\'re about to enter the fitness world. This place is not soft.\n\n'
            'This app will push you. It will call you out when you slack. It uses aggressive language to wake you up. '
            'If you can\'t handle the heat, hit the back button. '
            'If you\'re ready to actually put in the work — welcome.',
            style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.7),
          ),
          const Spacer(flex: 2),
          _PrimaryButton(label: 'I\'M READY. LET\'S GO', onPressed: onContinue),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => SystemNavigator.pop(),
              child: const Text(
                'I\'m not ready (Exit App)',
                style: TextStyle(color: AppColors.textHint),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Icon(Icons.lock_outline, color: AppColors.primary, size: 48),
          const SizedBox(height: 24),
          const Text(
            'Your data stays with you.',
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
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.$1,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary)),
                        Text(item.$2,
                            style: const TextStyle(
                                color: AppColors.textSecondary, height: 1.5)),
                      ],
                    ),
                  ),
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

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onContinue;
  const _NamePage({required this.controller, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(),
          const Text(
            'What should we call you?',
            style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          const Text(
            'Don\'t overthink it. Just your name. We\'ll be using it a lot.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Your name...',
              hintStyle:
                  TextStyle(color: AppColors.textHint.withValues(alpha: 0.5)),
              border: InputBorder.none,
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.borderDark, width: 2)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          const Spacer(flex: 2),
          _PrimaryButton(label: 'THAT\'S ME', onPressed: onContinue),
        ],
      ),
    );
  }
}

class _ProfileSetupPage extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController targetWeightController;
  final int weeklyGoal;
  final ValueChanged<int> onGoalChanged;
  final VoidCallback onFinish;

  const _ProfileSetupPage({
    required this.heightController,
    required this.weightController,
    required this.targetWeightController,
    required this.weeklyGoal,
    required this.onGoalChanged,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            const Text(
              'Set up your profile.',
              style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'We need these to track your progress. No vague answers.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 28),
            _InputField(
                label: 'Height (cm)',
                controller: heightController,
                inputType: TextInputType.number),
            const SizedBox(height: 16),
            _InputField(
                label: 'Current Weight (kg)',
                controller: weightController,
                inputType: TextInputType.number),
            const SizedBox(height: 16),
            _InputField(
                label: 'Target Weight (kg)',
                controller: targetWeightController,
                inputType: TextInputType.number),
            const SizedBox(height: 24),
            const Text(
              'Weekly Gym Goal',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(7, (i) {
                final day = i + 1;
                final selected = weeklyGoal == day;
                return GestureDetector(
                  onTap: () => onGoalChanged(day),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : AppColors.cardDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.borderDark),
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: TextStyle(
                            color: selected
                                ? Colors.black
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 36),
            _PrimaryButton(label: 'LET\'S GET TO WORK', onPressed: onFinish),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType inputType;

  const _InputField({
    required this.label,
    required this.controller,
    required this.inputType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: inputType,
          style: const TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.cardDark,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderDark)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderDark)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
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
