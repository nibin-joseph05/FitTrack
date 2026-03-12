import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen>
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
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(_fadeController);
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

  String? _nameErrorText;
  String? _heightErrorText;
  String? _weightErrorText;
  String? _targetWeightErrorText;
  String? _weeklyGoalErrorText;

  void _nextPage() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameErrorText =
          'I\'m sorry, are you nameless? Or just too lazy to type?');
      return;
    }

    if (name.length < 3) {
      setState(() =>
          _nameErrorText = '"$name"? Do you have a real name or just letters?');
      return;
    }

    if (name.length > 20) {
      setState(() => _nameErrorText =
          'Alright Your Highness, keep it short. We don\'t got all day.');
      return;
    }

    setState(() => _nameErrorText = null);
    FocusScope.of(context).unfocus();
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

    if (heightText.isEmpty || weightText.isEmpty || targetText.isEmpty) {
      setState(() {
        if (heightText.isEmpty)
          _heightErrorText = 'Fill this in. Stop crying and type.';
        if (weightText.isEmpty)
          _weightErrorText = 'Fill this in. Stop crying and type.';
        if (targetText.isEmpty)
          _targetWeightErrorText = 'Fill this in. Stop crying and type.';
      });
      return;
    }

    final height = double.tryParse(heightText);
    final currentWeight = double.tryParse(weightText);
    final targetWeight = double.tryParse(targetText);

    bool hasError = false;

    if (height == null) {
      setState(() => _heightErrorText =
          'Do you not know what numbers are? Enter a real height.');
      hasError = true;
    } else if (height <= 0) {
      setState(() => _heightErrorText =
          'Zero height? What are you, a 2D drawing? Be serious.');
      hasError = true;
    } else if (height < 100) {
      setState(() => _heightErrorText =
          'Under 100cm? Unless you are a literal toddler, type your real height.');
      hasError = true;
    } else if (height > 250) {
      setState(() => _heightErrorText =
          'Over 250cm? Are you building a team for the NBA? Stop lying.');
      hasError = true;
    } else {
      setState(() => _heightErrorText = null);
    }

    if (currentWeight == null) {
      setState(() =>
          _weightErrorText = 'Weight requires numbers, genius. Enter it.');
      hasError = true;
    } else if (currentWeight <= 0) {
      setState(() => _weightErrorText =
          'Anti-gravity weight? Try typing a number that exists.');
      hasError = true;
    } else if (currentWeight < 30) {
      setState(() => _weightErrorText =
          'Under 30kg? A stiff breeze will blow you away. Eat something.');
      hasError = true;
    } else if (currentWeight > 300) {
      setState(() => _weightErrorText =
          'Over 300kg? Time to put the fork down immediately.');
      hasError = true;
    } else {
      setState(() => _weightErrorText = null);
    }

    if (targetWeight == null) {
      setState(() => _targetWeightErrorText =
          'You need a target. Aimless people fail here.');
      hasError = true;
    } else if (targetWeight <= 0) {
      setState(() => _targetWeightErrorText =
          'A target of zero means you disappear. Pick a real goal.');
      hasError = true;
    } else if (targetWeight < 30) {
      setState(() => _targetWeightErrorText =
          'Target under 30kg? Are you trying to cease existing? Try again.');
      hasError = true;
    } else if (targetWeight > 300) {
      setState(() => _targetWeightErrorText =
          'Targeting over 300kg? We don\'t train professional sumo wrestlers.');
      hasError = true;
    } else {
      setState(() => _targetWeightErrorText = null);
    }

    if (hasError) return;

    await ref.read(profileProvider.notifier).completeOnboarding(
          name: name,
          height: height!,
          currentWeight: currentWeight!,
          targetWeight: targetWeight!,
          weeklyGoal: _weeklyGoal,
        );

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.backgroundDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.primary, width: 2),
          ),
          title: const Text(
            'Welcome to the pain.',
            style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 24),
          ),
          content: const Text(
            'Your profile is set. You are going to suffer from now on. Don\'t say we didn\'t warn you.',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 16, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('BRING IT ON',
                  style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: AnimatedOpacity(
            opacity: _pageController.hasClients && _pageController.page == 1
                ? 1.0
                : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary, size: 20),
              onPressed: () {
                if (_pageController.hasClients && _pageController.page == 1) {
                  _pageController.previousPage(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut);
                  setState(() {});
                }
              },
            ),
          ),
        ),
        body: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (_) => setState(() {}),
              children: [
                _NamePage(
                  controller: _nameController,
                  onContinue: _nextPage,
                  errorText: _nameErrorText,
                ),
                _ProfileSetupPage(
                  name: _nameController.text.trim(),
                  heightController: _heightController,
                  weightController: _weightController,
                  targetWeightController: _targetWeightController,
                  weeklyGoal: _weeklyGoal,
                  heightErrorText: _heightErrorText,
                  weightErrorText: _weightErrorText,
                  targetWeightErrorText: _targetWeightErrorText,
                  weeklyGoalErrorText: _weeklyGoalErrorText,
                  onGoalChanged: (v) {
                    setState(() {
                      _weeklyGoal = v;
                      switch (v) {
                        case 1:
                          _weeklyGoalErrorText =
                              '1 day?! Why are you even bothering? Stay at your house.';
                          break;
                        case 2:
                          _weeklyGoalErrorText =
                              '2 days. You think that builds muscle? Have fun staying exactly the same.';
                          break;
                        case 3:
                          _weeklyGoalErrorText =
                              '3 days? Bare minimum. You can do better.';
                          break;
                        case 4:
                          _weeklyGoalErrorText =
                              '4 days. Now we\'re talking. Still room for improvement though.';
                          break;
                        case 5:
                          _weeklyGoalErrorText =
                              '5 days? Good. Keep that energy when your body aches.';
                          break;
                        case 6:
                          _weeklyGoalErrorText =
                              '6 days. Big talk. Let\'s see if you survive the week.';
                          break;
                        case 7:
                          _weeklyGoalErrorText =
                              '7 days? You\'re either a machine or lying to yourself. We\'ll see.';
                          break;
                      }
                    });
                  },
                  onFinish: _finish,
                  onHeightChanged: (val) {
                    setState(() {
                      final h = double.tryParse(val);
                      if (h != null) {
                        if (h <= 0)
                          _heightErrorText = '0 height? So you don\'t exist?';
                        else if (h < 150)
                          _heightErrorText =
                              'Bit short, aren\'t we? Lift heavy anyway.';
                        else if (h > 195 && h < 250)
                          _heightErrorText =
                              'Tall guys have no excuses. Fill out that frame.';
                        else if (h >= 250)
                          _heightErrorText =
                              'Stop lying. You are not 250cm tall.';
                        else
                          _heightErrorText = null;
                      } else {
                        _heightErrorText = null;
                      }
                    });
                  },
                  onWeightChanged: (val) {
                    setState(() {
                      final w = double.tryParse(val);
                      if (w != null) {
                        if (w <= 0)
                          _weightErrorText =
                              'Zero weight? Physics doesn\'t work like that here.';
                        else if (w < 50)
                          _weightErrorText =
                              'You weigh nothing. You need to eat. Immediately.';
                        else if (w > 120 && w < 300)
                          _weightErrorText =
                              'Carrying a lot of excess baggage. Time to put in work.';
                        else if (w >= 300)
                          _weightErrorText =
                              'Over 300kg? Put the fork down right now.';
                        else
                          _weightErrorText = null;
                      } else {
                        _weightErrorText = null;
                      }
                    });
                  },
                  onTargetWeightChanged: (val) {
                    setState(() {
                      final t = double.tryParse(val);
                      final w = double.tryParse(_weightController.text);
                      if (t != null && w != null) {
                        if (t == w)
                          _targetWeightErrorText =
                              'Target equals current? Complacency gets you nowhere.';
                        else if (t < 40)
                          _targetWeightErrorText =
                              'Aiming for a skeleton build? Dream bigger.';
                        else if ((w - t).abs() > 40)
                          _targetWeightErrorText =
                              'Big dreams. But can you survive the reality of the work?';
                        else
                          _targetWeightErrorText = null;
                      } else {
                        _targetWeightErrorText = null;
                      }
                    });
                  },
                ),
              ],
            ),
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
      padding: const EdgeInsets.only(left: 28, right: 28, bottom: 24),
      child: child,
    );
  }
}

class _NamePage extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onContinue;
  final String? errorText;

  const _NamePage({
    required this.controller,
    required this.onContinue,
    this.errorText,
  });

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
                  borderSide:
                      BorderSide(color: AppColors.borderDark, width: 2)),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
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
  final String name;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final TextEditingController targetWeightController;
  final int weeklyGoal;
  final ValueChanged<int> onGoalChanged;
  final VoidCallback onFinish;
  final ValueChanged<String>? onHeightChanged;
  final ValueChanged<String>? onWeightChanged;
  final ValueChanged<String>? onTargetWeightChanged;

  final String? heightErrorText;
  final String? weightErrorText;
  final String? targetWeightErrorText;
  final String? weeklyGoalErrorText;

  const _ProfileSetupPage({
    required this.name,
    required this.heightController,
    required this.weightController,
    required this.targetWeightController,
    required this.weeklyGoal,
    required this.onGoalChanged,
    required this.onFinish,
    this.onHeightChanged,
    this.onWeightChanged,
    this.onTargetWeightChanged,
    this.heightErrorText,
    this.weightErrorText,
    this.targetWeightErrorText,
    this.weeklyGoalErrorText,
  });

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Welcome, ${name.isEmpty ? "Nobody" : name}.',
              style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Now finish your profile. And don\'t lie about your numbers, we\'ll know.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 28),
            _InputField(
              label: 'Height (cm)',
              controller: heightController,
              inputType: TextInputType.number,
              onChanged: onHeightChanged,
              errorText: heightErrorText,
            ),
            const SizedBox(height: 16),
            _InputField(
              label: 'Current Weight (kg)',
              controller: weightController,
              inputType: TextInputType.number,
              onChanged: onWeightChanged,
              errorText: weightErrorText,
            ),
            const SizedBox(height: 16),
            _InputField(
              label: 'Target Weight (kg)',
              controller: targetWeightController,
              inputType: TextInputType.number,
              onChanged: onTargetWeightChanged,
              errorText: targetWeightErrorText,
            ),
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
                      color: selected ? AppColors.primary : AppColors.cardDark,
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
            if (weeklyGoalErrorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  weeklyGoalErrorText!,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
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
  final ValueChanged<String>? onChanged;
  final String? errorText;

  const _InputField({
    required this.label,
    required this.controller,
    required this.inputType,
    this.onChanged,
    this.errorText,
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
          onChanged: onChanged,
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
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
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
                fontWeight: FontWeight.w800, fontSize: 15, letterSpacing: 0.5)),
      ),
    );
  }
}
