class FormatUtils {
  static String formatWeight(double weight) {
    if (weight == weight.roundToDouble()) {
      return '${weight.toInt()} kg';
    }
    return '${weight.toStringAsFixed(1)} kg';
  }

  static String formatWeightCompact(double weight) {
    if (weight == weight.roundToDouble()) {
      return weight.toInt().toString();
    }
    return weight.toStringAsFixed(1);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  static String formatVolume(double volume) {
    if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}k kg';
    }
    return '${volume.toInt()} kg';
  }

  static String formatReps(int reps) {
    return '$reps ${reps == 1 ? 'rep' : 'reps'}';
  }

  static String formatSets(int sets) {
    return '$sets ${sets == 1 ? 'set' : 'sets'}';
  }

  static String formatPercentChange(double oldVal, double newVal) {
    if (oldVal == 0) return '+0%';
    final change = ((newVal - oldVal) / oldVal) * 100;
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)}%';
  }

  static String ordinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1:
        return '${n}st';
      case 2:
        return '${n}nd';
      case 3:
        return '${n}rd';
      default:
        return '${n}th';
    }
  }
}
