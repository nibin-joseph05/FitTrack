import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int initialSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;

  const TimerWidget({
    super.key,
    required this.initialSeconds,
    required this.remainingSeconds,
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onReset,
  });

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress =
        initialSeconds > 0 ? remainingSeconds / initialSeconds : 0.0;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 8,
                backgroundColor: Colors.grey.withOpacity(0.2),
                color: remainingSeconds < 10 ? Colors.red : primaryColor,
              ),
            ),
            Text(
              _formatTime(remainingSeconds),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              iconSize: 48,
              icon: Icon(
                isRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: primaryColor,
              ),
              onPressed: isRunning ? onPause : onStart,
            ),
            const SizedBox(width: 16),
            IconButton(
              iconSize: 32,
              icon: const Icon(Icons.stop_circle, color: Colors.grey),
              onPressed: onReset,
            ),
          ],
        ),
      ],
    );
  }
}
