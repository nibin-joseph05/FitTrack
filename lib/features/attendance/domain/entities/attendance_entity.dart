class AttendanceEntity {
  final DateTime date;
  final bool attended;

  const AttendanceEntity({
    required this.date,
    required this.attended,
  });

  AttendanceEntity copyWith({
    DateTime? date,
    bool? attended,
  }) {
    return AttendanceEntity(
      date: date ?? this.date,
      attended: attended ?? this.attended,
    );
  }
}
