import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/timer_provider.dart';
import '../../../../shared/widgets/timer_widget.dart';

class TimerScreen extends ConsumerWidget {
  const TimerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTimer = ref.watch(activeTimerProvider);
    final savedTimersAsync = ref.watch(savedTimersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Rest Timer')),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Center(
            child: TimerWidget(
              initialSeconds: activeTimer.initialSeconds,
              remainingSeconds: activeTimer.remainingSeconds,
              isRunning: activeTimer.isRunning,
              onStart: () => ref.read(activeTimerProvider.notifier).start(),
              onPause: () => ref.read(activeTimerProvider.notifier).pause(),
              onReset: () => ref.read(activeTimerProvider.notifier).reset(),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Saved Timers',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => _showAddTimerDialog(context, ref),
                  child: const Text('+ Add New'),
                ),
              ],
            ),
          ),
          Expanded(
            child: savedTimersAsync.when(
              data: (timers) {
                if (timers.isEmpty) {
                  return const Center(child: Text('No saved timers.'));
                }
                return ListView.builder(
                  itemCount: timers.length,
                  itemBuilder: (context, index) {
                    final t = timers[index];
                    return ListTile(
                      leading: const Icon(Icons.timer),
                      title: Text(t.name),
                      subtitle: Text(
                          '${t.defaultDurationSeconds ~/ 60}:${(t.defaultDurationSeconds % 60).toString().padLeft(2, '0')}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          ref
                              .read(activeTimerProvider.notifier)
                              .setDuration(t.defaultDurationSeconds);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTimerDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final secCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Custom Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Timer Name (e.g., Custom)')),
            const SizedBox(height: 8),
            TextField(
                controller: secCtrl,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: 'Duration in Seconds')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final sec = int.tryParse(secCtrl.text.trim()) ?? 60;
              if (name.isNotEmpty) {
                ref.read(savedTimersProvider.notifier).savePreset(name, sec);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
