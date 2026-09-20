import 'package:flutter/material.dart';

import '../../models/habit.dart';
import '../today/add_habit_screen.dart';
import '../../services/habit_storage.dart';

class HabitDetailScreen extends StatefulWidget {
  const HabitDetailScreen({
    super.key,
    required this.habit,
    this.onHabitUpdated,
    this.onHabitDeleted,
  });

  final Habit habit;
  final ValueChanged<Habit>? onHabitUpdated;
  final VoidCallback? onHabitDeleted;

  @override
  State<HabitDetailScreen> createState() =>
      _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late DateTime _displayedMonth;

  Habit get habit => widget.habit;

  @override
  void initState() {
    super.initState();

    final now = DateTime.now();

    _displayedMonth = DateTime(
      now.year,
      now.month,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = _calculateCurrentStreak();
    final bestStreak = _calculateBestStreak();
    final totalCompletions = habit.completedDates.length;
    final completionRate = _calculateCompletionRate();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FD),
appBar: AppBar(
  title: const Text(
    'Habit Details',
    style: TextStyle(
      fontWeight: FontWeight.w800,
    ),
  ),
  actions: [
    IconButton(
      tooltip: 'Edit',
      icon: const Icon(Icons.edit_outlined),
      onPressed: _editHabit,
    ),
    IconButton(
      tooltip: 'Delete',
      icon: const Icon(Icons.delete_outline),
      onPressed: _deleteHabit,
    ),
    const SizedBox(width: 8),
  ],
),
     
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHabitHeader(),

            const SizedBox(height: 24),

            _buildStats(
              currentStreak: currentStreak,
              bestStreak: bestStreak,
              totalCompletions: totalCompletions,
              completionRate: completionRate,
            ),

            const SizedBox(height: 28),

            const Text(
              'History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 12),

            _buildCalendar(),

            const SizedBox(height: 24),

            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HABIT HEADER
  // ============================================================

  Widget _buildHabitHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _parseColor(habit.colorHex),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              _getIcon(habit.icon),
              size: 30,
              color: const Color(0xFF111827),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  habit.category,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS
  // ============================================================

  Widget _buildStats({
    required int currentStreak,
    required int bestStreak,
    required int totalCompletions,
    required int completionRate,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          title: 'Current Streak',
          value: '$currentStreak',
          suffix: ' days',
          icon: Icons.local_fire_department_outlined,
        ),
        _StatCard(
          title: 'Best Streak',
          value: '$bestStreak',
          suffix: ' days',
          icon: Icons.emoji_events_outlined,
        ),
        _StatCard(
          title: 'Completed',
          value: '$totalCompletions',
          suffix: ' days',
          icon: Icons.check_circle_outline,
        ),
        _StatCard(
          title: 'Completion',
          value: '$completionRate',
          suffix: '%',
          icon: Icons.insights_outlined,
        ),
      ],
    );
  }

  // ============================================================
  // CALENDAR
  // ============================================================

  Widget _buildCalendar() {
    final firstDay = DateTime(
      _displayedMonth.year,
      _displayedMonth.month,
      1,
    );

    final daysInMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
      0,
    ).day;

    final startingWeekday = firstDay.weekday;

    final now = DateTime.now();

    final currentMonth = DateTime(
      now.year,
      now.month,
    );

    final canGoNext = _displayedMonth.isBefore(currentMonth);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _displayedMonth = DateTime(
                      _displayedMonth.year,
                      _displayedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(
                  Icons.chevron_left,
                ),
              ),

              Expanded(
                child: Center(
                  child: Text(
                    '${_monthName(_displayedMonth.month)} '
                    '${_displayedMonth.year}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
              ),

              IconButton(
                onPressed: canGoNext
                    ? () {
                        setState(() {
                          _displayedMonth = DateTime(
                            _displayedMonth.year,
                            _displayedMonth.month + 1,
                          );
                        });
                      }
                    : null,
                icon: const Icon(
                  Icons.chevron_right,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: const [
              _WeekdayLabel('M'),
              _WeekdayLabel('T'),
              _WeekdayLabel('W'),
              _WeekdayLabel('T'),
              _WeekdayLabel('F'),
              _WeekdayLabel('S'),
              _WeekdayLabel('S'),
            ],
          ),

          const SizedBox(height: 8),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: startingWeekday - 1 + daysInMonth,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              if (index < startingWeekday - 1) {
                return const SizedBox();
              }

              final day = index - startingWeekday + 2;

              final date = DateTime(
                _displayedMonth.year,
                _displayedMonth.month,
                day,
              );

              final completed = habit.isCompletedOn(date);

              final today = _isToday(date);

              final future = date.isAfter(
                DateTime(
                  now.year,
                  now.month,
                  now.day,
                ),
              );

              return _CalendarDay(
                day: day,
                completed: completed,
                today: today,
                future: future,
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO
  // ============================================================

  Widget _buildInfoCard() {
    String scheduleText;

    if (habit.scheduleType == HabitScheduleType.daily) {
      scheduleText = 'Every day';
    } else {
      scheduleText = habit.activeDays
          .map(_weekdayName)
          .join(', ');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Habit Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827),
            ),
          ),

          const SizedBox(height: 18),

          _InfoRow(
            icon: Icons.repeat,
            title: 'Schedule',
            value: scheduleText,
          ),

          if (habit.reminderEnabled) ...[
            const SizedBox(height: 14),
            _InfoRow(
              icon: Icons.notifications_none,
              title: 'Reminder',
              value: habit.reminderTime ?? 'Enabled',
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // STREAK
  // ============================================================

  int _calculateCurrentStreak() {
    int streak = 0;

    DateTime date = DateTime.now();

    while (true) {
      final day = DateTime(
        date.year,
        date.month,
        date.day,
      );

      if (!habit.isScheduledOn(day)) {
        date = date.subtract(
          const Duration(days: 1),
        );
        continue;
      }

      if (habit.isCompletedOn(day)) {
        streak++;
        date = date.subtract(
          const Duration(days: 1),
        );
      } else {
        break;
      }
    }

    return streak;
  }

  int _calculateBestStreak() {
    if (habit.completedDates.isEmpty) {
      return 0;
    }

    final dates = habit.completedDates
        .map(_parseDate)
        .whereType<DateTime>()
        .toList();

    dates.sort();

    int best = 0;
    int current = 0;

    DateTime? previous;

    for (final date in dates) {
      if (previous == null) {
        current = 1;
      } else {
        final difference = date.difference(previous).inDays;

        if (difference == 1) {
          current++;
        } else if (difference > 1) {
          current = 1;
        }
      }

      if (current > best) {
        best = current;
      }

      previous = date;
    }

    return best;
  }

  int _calculateCompletionRate() {
    if (habit.completedDates.isEmpty) {
      return 0;
    }

    final created = DateTime(
      habit.createdAt.year,
      habit.createdAt.month,
      habit.createdAt.day,
    );

    final today = DateTime.now();

    final totalDays =
        today.difference(created).inDays + 1;

    if (totalDays <= 0) {
      return 0;
    }

    final completed = habit.completedDates.length;

    final rate =
        ((completed / totalDays) * 100).round();

    return rate.clamp(0, 100);
  }

Future<void> _editHabit() async {
  final updatedHabit = await Navigator.push<Habit>(
    context,
    MaterialPageRoute(
      builder: (_) => AddHabitScreen(
        habit: widget.habit,
      ),
    ),
  );

  if (updatedHabit == null || !mounted) {
    return;
  }

  widget.onHabitUpdated?.call(updatedHabit);

  setState(() {
    // Refresh the detail screen.
  });
}

Future<void> _deleteHabit() async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'Delete habit?',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Are you sure you want to delete '
          '"${widget.habit.name}"?\n\n'
          'All of its completion history will also be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirmed != true) {
    return;
  }

  await HabitStorage.deleteHabit(widget.habit.id);

  if (!mounted) return;

  widget.onHabitDeleted?.call();

  Navigator.pop(context);
}

  // ============================================================
  // HELPERS
  // ============================================================

  DateTime? _parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  String _monthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[weekday - 1];
  }

  Color _parseColor(String hex) {
    final value = hex.replaceAll('#', '');

    return Color(
      int.parse(
        'FF$value',
        radix: 16,
      ),
    );
  }

  IconData _getIcon(String icon) {
    switch (icon) {
      case 'run':
        return Icons.directions_run;
      case 'book':
        return Icons.menu_book;
      case 'water':
        return Icons.water_drop;
      case 'focus':
        return Icons.center_focus_strong;
      case 'shower':
        return Icons.shower;
      case 'journal':
        return Icons.edit_note;
      case 'exercise':
        return Icons.fitness_center;
      case 'meditation':
        return Icons.self_improvement;
      default:
        return Icons.check_circle_outline;
    }
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
  });

  final String title;
  final String value;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xFF00865A),
          ),

          const Spacer(),

          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),

          const SizedBox(height: 2),

          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                TextSpan(
                  text: suffix,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CALENDAR DAY
// ============================================================

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.day,
    required this.completed,
    required this.today,
    required this.future,
  });

  final int day;
  final bool completed;
  final bool today;
  final bool future;

  @override
  Widget build(BuildContext context) {
    Color background = Colors.transparent;
    Color textColor = const Color(0xFF374151);

    if (completed) {
      background = const Color(0xFF00865A);
      textColor = Colors.white;
    } else if (today) {
      background = const Color(0xFFE9EBFF);
      textColor = const Color(0xFF00865A);
    } else if (future) {
      textColor = const Color(0xFFD1D5DB);
    }

    return Center(
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          border: today && !completed
              ? Border.all(
                  color: const Color(0xFF00865A),
                  width: 1.5,
                )
              : null,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                today || completed
                    ? FontWeight.w800
                    : FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WEEKDAY LABEL
// ============================================================

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF4B5563),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9CA3AF),
                ),
              ),

              const SizedBox(height: 2),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}