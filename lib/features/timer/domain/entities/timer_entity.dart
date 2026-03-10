class TimerEntity {
  final String id;
  final String name;
  final int defaultDurationSeconds;

  const TimerEntity({
    required this.id,
    required this.name,
    required this.defaultDurationSeconds,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TimerEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
