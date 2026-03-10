class BodyMetricEntity {
  final String id;
  final DateTime date;
  final double? weightKg;
  final double? bodyFatPercent;
  final double? chestCm;
  final double? waistCm;
  final double? hipCm;
  final double? armCm;
  final double? thighCm;
  final String? notes;

  const BodyMetricEntity({
    required this.id,
    required this.date,
    this.weightKg,
    this.bodyFatPercent,
    this.chestCm,
    this.waistCm,
    this.hipCm,
    this.armCm,
    this.thighCm,
    this.notes,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is BodyMetricEntity && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
