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

  void _showBrutalSnackbar(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _nextPage() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showBrutalSnackbar('I\'m sorry, are you nameless? Or just too lazy to type?');
      return;
    }
    
    if (name.length < 3) {
      _showBrutalSnackbar('"$name"? What kind of name is that? Be serious.');
      return;
    }

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
      _showBrutalSnackbar('Fill in all fields. Stop crying and type.');
      return;
    }

    final height = double.tryParse(heightText);
    final currentWeight = double.tryParse(weightText);
    final targetWeight = double.tryParse(targetText);

    if (height == null) {
      _showBrutalSnackbar('Do you not know what numbers are? Enter a real height.');
      return;
    } else if (height <= 0) {
      _showBrutalSnackbar('Zero height? What are you, a 2D drawing? Be serious.');
      return;
    } else if (height < 100) {
      _showBrutalSnackbar('Under 100cm? Unless you are a literal toddler, type your real height.');
      return;
    } else if (height > 250) {
      _showBrutalSnackbar('Over 250cm? Are you building a team for the NBA? Stop lying.');
      return;
    }

    if (currentWeight == null) {
      _showBrutalSnackbar('Weight requires numbers, genius. Enter it.');
      return;
    } else if (currentWeight <= 0) {
      _showBrutalSnackbar('Anti-gravity weight? Try typing a number that exists.');
      return;
    } else if (currentWeight < 30) {
      _showBrutalSnackbar('Under 30kg? A stiff breeze will blow you away. Eat something.');
      return;
    } else if (currentWeight > 300) {
      _showBrutalSnackbar('Over 300kg? Time to put the fork down immediately.');
      return;
    }
    
    if (targetWeight == null) {
      _showBrutalSnackbar('You need a target. Aimless people fail here.');
      return;
    } else if (targetWeight <= 0) {
      _showBrutalSnackbar('A target of zero means you disappear. Pick a real goal.');
      return;
    } else if (targetWeight < 30) {
      _showBrutalSnackbar('Target under 30kg? Are you trying to cease existing? Try again.');
      return;
    } else if (targetWeight > 300) {
      _showBrutalSnackbar('Targeting over 300kg? We don\'t train professional sumo wrestlers.');
      return;
    }

    await ref.read(profileProvider.notifier).completeOnboarding(
          name: name,
          height: height,
          currentWeight: currentWeight,
          targetWeight: targetWeight,
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
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w900, fontSize: 24),
          ),
          content: const Text(
            'Your profile is set. You are going to suffer from now on. Don\'t say we didn\'t warn you.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16, height: 1.5),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('BRING IT ON', style: TextStyle(fontWeight: FontWeight.w900)),
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
            opacity: _pageController.hasClients && _pageController.page == 1 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 20),
              onPressed: () {
                if (_pageController.hasClients && _pageController.page == 1) {
                  _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
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
                  showBrutalSnackbar: _showBrutalSnackbar,
                ),
                _ProfileSetupPage(
                  heightController: _heightController,
                  weightController: _weightController,
                  targetWeightController: _targetWeightController,
                  weeklyGoal: _weeklyGoal,
                  onGoalChanged: (v) {
                    setState(() => _weeklyGoal = v);
                    switch (v) {
                      case 1:
                        _showBrutalSnackbar('1 day?! Why are you even bothering? Stay at your house.');
                        break;
                      case 2:
                        _showBrutalSnackbar('2 days. You think that builds muscle? Have fun staying exactly the same.');
                        break;
                      case 3:
                        _showBrutalSnackbar('3 days? Bare minimum. You can do better.');
                        break;
                      case 4:
                        _showBrutalSnackbar('4 days. Now we\'re talking. Still room for improvement though.');
                        break;
                      case 5:
                        _showBrutalSnackbar('5 days? Good. Keep that energy when your body aches.');
                        break;
                      case 6:
                        _showBrutalSnackbar('6 days. Big talk. Let\'s see if you survive the week.');
                        break;
                      case 7:
                        _showBrutalSnackbar('7 days? You\'re either a machine or lying to yourself. We\'ll see.');
                        break;
                    }
                  },
                  onFinish: _finish,
                  showBrutalSnackbar: _showBrutalSnackbar,
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
  final void Function(String) showBrutalSnackbar;
  const _NamePage({
    required this.controller, 
    required this.onContinue,
    required this.showBrutalSnackbar,
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
            onChanged: (val) {
              if (val.isNotEmpty && val.length < 3) {
                showBrutalSnackbar('"$val"? Do you have a real name or just letters?');
              } else if (val.length > 20) {
                showBrutalSnackbar('Alright Your Highness, keep it short. We don\'t got all day.');
              }
            },
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
  final void Function(String) showBrutalSnackbar;

  const _ProfileSetupPage({
    required this.heightController,
    required this.weightController,
    required this.targetWeightController,
    required this.weeklyGoal,
    required this.onGoalChanged,
    required this.onFinish,
    required this.showBrutalSnackbar,
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
                inputType: TextInputType.number,
                onChanged: (val) {
                  final h = double.tryParse(val);
                  if (h != null) {
                    if (h <= 0) showBrutalSnackbar('0 height? So you don\'t exist?');
                    else if (h < 150) showBrutalSnackbar('Bit short, aren\'t we? Lift heavy anyway.');
                    else if (h > 195 && h < 250) showBrutalSnackbar('Tall guys have no excuses. Fill out that frame.');
                    else if (h >= 250) showBrutalSnackbar('Stop lying. You are not 250cm tall.');
                  }
                },
            ),
            const SizedBox(height: 16),
            _InputField(
                label: 'Current Weight (kg)',
                controller: weightController,
                inputType: TextInputType.number,
                onChanged: (val) {
                  final w = double.tryParse(val);
                  if (w != null) {
                    if (w <= 0) showBrutalSnackbar('Zero weight? Physics doesn\'t work like that here.');
                    else if (w < 50) showBrutalSnackbar('You weigh nothing. You need to eat. Immediately.');
                    else if (w > 120 && w < 300) showBrutalSnackbar('Carrying a lot of excess baggage. Time to put in work.');
                    else if (w >= 300) showBrutalSnackbar('Over 300kg? Put the fork down right now.');
                  }
                },
            ),
            const SizedBox(height: 16),
            _InputField(
                label: 'Target Weight (kg)',
                controller: targetWeightController,
                inputType: TextInputType.number,
                onChanged: (val) {
                  final t = double.tryParse(val);
                  final w = double.tryParse(weightController.text);
                  if (t != null && w != null) {
                    if (t == w) showBrutalSnackbar('Target equals current? Complacency gets you nowhere.');
                    else if (t < 40) showBrutalSnackbar('Aiming for a skeleton build? Dream bigger.');
                    else if ((w - t).abs() > 40) showBrutalSnackbar('Big dreams. But can you survive the reality of the work?');
                  }
                },
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
  final ValueChanged<String>? onChanged;

  const _InputField({
    required this.label,
    required this.controller,
    required this.inputType,
    this.onChanged,
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
