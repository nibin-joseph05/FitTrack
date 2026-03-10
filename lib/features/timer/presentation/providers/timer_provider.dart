import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/timer_entity.dart';
import '../../data/repositories/timer_repository_impl.dart';

class TimerNotifier extends AsyncNotifier<List<TimerEntity>> {
  @override
  Future<List<TimerEntity>> build() async {
    final repo = ref.read(timerRepositoryProvider);
    return repo.getAllTimers();
  }

  Future<void> savePreset(String name, int seconds) async {
    const uuid = Uuid();
    final timer = TimerEntity(
      id: uuid.v4(),
      name: name,
      defaultDurationSeconds: seconds,
    );
    await ref.read(timerRepositoryProvider).saveTimer(timer);
    ref.invalidateSelf();
  }

  Future<void> deletePreset(String id) async {
    await ref.read(timerRepositoryProvider).deleteTimer(id);
    ref.invalidateSelf();
  }
}

final savedTimersProvider =
    AsyncNotifierProvider<TimerNotifier, List<TimerEntity>>(
  TimerNotifier.new,
);

class ActiveTimerState {
  final int remainingSeconds;
  final bool isRunning;
  final int initialSeconds;

  ActiveTimerState({
    required this.remainingSeconds,
    required this.isRunning,
    required this.initialSeconds,
  });

  ActiveTimerState copyWith({
    int? remainingSeconds,
    bool? isRunning,
    int? initialSeconds,
  }) {
    return ActiveTimerState(
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      initialSeconds: initialSeconds ?? this.initialSeconds,
    );
  }
}

class ActiveTimerNotifier extends Notifier<ActiveTimerState> {
  @override
  ActiveTimerState build() {
    return ActiveTimerState(
      remainingSeconds: 60,
      isRunning: false,
      initialSeconds: 60,
    );
  }

  void start() {
    state = state.copyWith(isRunning: true);
  }

  void pause() {
    state = state.copyWith(isRunning: false);
  }

  void reset() {
    state = state.copyWith(
      remainingSeconds: state.initialSeconds,
      isRunning: false,
    );
  }

  void setDuration(int seconds) {
    state = state.copyWith(
      initialSeconds: seconds,
      remainingSeconds: seconds,
      isRunning: false,
    );
  }

  void tick() {
    if (state.isRunning && state.remainingSeconds > 0) {
      state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
    } else if (state.remainingSeconds == 0) {
      state = state.copyWith(isRunning: false);
    }
  }
}

final activeTimerProvider =
    NotifierProvider<ActiveTimerNotifier, ActiveTimerState>(
  ActiveTimerNotifier.new,
);
