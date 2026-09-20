enum HabitScheduleType {
  daily,
  specificDays,
}

class Habit {
  final String id;
  final String name;
  final String category;
  final String icon;
  final String colorHex;

  final HabitScheduleType scheduleType;
  final List<int> activeDays;

  final bool reminderEnabled;
  final String? reminderTime;

  // Stores completion timestamps.
  //
  // Example:
  // 2026-09-19T07:42:15.123
  final List<String> completedDates;

  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.icon,
    required this.colorHex,
    required this.scheduleType,
    required List<int> activeDays,
    required this.reminderEnabled,
    required this.reminderTime,
    required List<String> completedDates,
    required this.createdAt,
  })  : activeDays = List<int>.from(activeDays),
        completedDates = List<String>.from(completedDates);

  // ============================================================
  // COMPLETION
  // ============================================================

  bool isCompletedOn(DateTime date) {
    final key = _dateKey(date);

    return completedDates.any(
      (value) {
        // New format:
        // 2026-09-19T07:42:15
        if (value.startsWith('$key' 'T')) {
          return true;
        }

        // Old format:
        // 2026-09-19
        //
        // This keeps existing saved data working.
        return value == key;
      },
    );
  }

  void markCompleted(DateTime date) {
    final key = _dateKey(date);

    // Remove any existing completion for this date.
    completedDates.removeWhere(
      (value) {
        return value == key || value.startsWith('$key' 'T');
      },
    );

    // Store the actual completion time.
    completedDates.add(
      date.toIso8601String(),
    );
  }

  void markIncomplete(DateTime date) {
    final key = _dateKey(date);

    completedDates.removeWhere(
      (value) {
        return value == key || value.startsWith('$key' 'T');
      },
    );
  }

  // ============================================================
  // COMPLETION TIME
  // ============================================================

  DateTime? completionTimeOn(DateTime date) {
    final key = _dateKey(date);

    for (final value in completedDates) {
      if (value.startsWith('$key' 'T')) {
        return DateTime.tryParse(value);
      }
    }

    return null;
  }

  bool wasCompletedBefore(DateTime date, int hour) {
    final completion = completionTimeOn(date);

    if (completion == null) {
      return false;
    }

    return completion.hour < hour;
  }

  bool wasCompletedAfter(DateTime date, int hour) {
    final completion = completionTimeOn(date);

    if (completion == null) {
      return false;
    }

    return completion.hour >= hour;
  }

  // ============================================================
  // SCHEDULE
  // ============================================================

  bool isScheduledOn(DateTime date) {
    if (scheduleType == HabitScheduleType.daily) {
      return true;
    }

    return activeDays.contains(date.weekday);
  }

  // ============================================================
  // JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'icon': icon,
      'colorHex': colorHex,
      'scheduleType': scheduleType.name,
      'activeDays': activeDays,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'completedDates': completedDates,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      icon: json['icon'] as String,
      colorHex: json['colorHex'] as String,
      scheduleType: HabitScheduleType.values.firstWhere(
        (value) => value.name == json['scheduleType'],
        orElse: () => HabitScheduleType.daily,
      ),
      activeDays: List<int>.from(
        json['activeDays'] ?? [],
      ),
      reminderEnabled: json['reminderEnabled'] ?? false,
      reminderTime: json['reminderTime'],
      completedDates: List<String>.from(
        json['completedDates'] ?? [],
      ),
      createdAt: DateTime.parse(
        json['createdAt'] as String,
      ),
    );
  }

  // ============================================================
  // DATE KEY
  // ============================================================

  static String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }
}