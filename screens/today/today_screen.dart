import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/habit.dart';
import '../../services/habit_storage.dart';
import 'add_habit_screen.dart';
import '../habit_detail/habit_detail_screen.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({
    super.key,
    required this.habits,
  });

  final List<Habit> habits;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  String _filter = 'all';

  DateTime get _today => DateTime.now();

  // ------------------------------------------------------------
  // HABIT DATA
  // ------------------------------------------------------------

  List<Habit> get _todayHabits {
    return widget.habits.where((habit) {
      return habit.isScheduledOn(_today);
    }).toList();
  }

  List<Habit> get _completedToday {
    return _todayHabits.where((habit) {
      return habit.isCompletedOn(_today);
    }).toList();
  }

  List<Habit> get _pendingToday {
    return _todayHabits.where((habit) {
      return !habit.isCompletedOn(_today);
    }).toList();
  }

  List<Habit> get _filteredHabits {
    switch (_filter) {
      case 'pending':
        return _pendingToday;

      case 'completed':
        return _completedToday;

      case 'all':
      default:
        return _todayHabits;
    }
  }

  double get _dailyProgress {
    if (_todayHabits.isEmpty) {
      return 0;
    }

    return _completedToday.length / _todayHabits.length;
  }

  // ------------------------------------------------------------
  // OVERALL STREAK
  // ------------------------------------------------------------

  int get _overallStreak {
    int streak = 0;

    DateTime date = DateTime(
      _today.year,
      _today.month,
      _today.day,
    );

    while (true) {
      final scheduled = widget.habits.where(
        (habit) => habit.isScheduledOn(date),
      ).toList();

      // If there were no habits scheduled that day,
      // don't break the streak.
      if (scheduled.isEmpty) {
        date = date.subtract(
          const Duration(days: 1),
        );
        continue;
      }

      final completed = scheduled.every(
        (habit) => habit.isCompletedOn(date),
      );

      if (!completed) {
        break;
      }

      streak++;

      date = date.subtract(
        const Duration(days: 1),
      );
    }

    return streak;
  }

  // ------------------------------------------------------------
  // COMPLETE / UNCOMPLETE HABIT
  // ------------------------------------------------------------

  Future<void> _toggleHabit(Habit habit) async {
    final today = DateTime.now();

    setState(() {
      if (habit.isCompletedOn(today)) {
        habit.markIncomplete(today);
      } else {
        habit.markCompleted(today);
      }
    });

    await HabitStorage.saveHabit(habit);
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeader(),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              100,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStreakCard(),

                const SizedBox(height: 18),

                _buildWeeklyChain(),

                const SizedBox(height: 18),

                _buildFilters(),

                const SizedBox(height: 16),

                // REAL FILTERED HABITS
                ..._filteredHabits.map(
                  (habit) => _HabitCard(
  habit: habit,
  completed: habit.isCompletedOn(DateTime.now()),
  onToggle: () => _toggleHabit(habit),
onTap: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => HabitDetailScreen(
        habit: habit,

        onHabitUpdated: (updatedHabit) {
          setState(() {
            final index = widget.habits.indexWhere(
              (item) => item.id == updatedHabit.id,
            );

            if (index != -1) {
              widget.habits[index] = updatedHabit;
            }
          });
        },

        onHabitDeleted: () {
          setState(() {
            widget.habits.removeWhere(
              (item) => item.id == habit.id,
            );
          });
        },
      ),
    ),
  );
},
)
                ),



                if (_filteredHabits.isEmpty)
                  _buildEmptyState(),

                const SizedBox(height: 16),

               
              ]),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddHabitScreen(
                onHabitCreated: (habit) {
                  setState(() {
                    widget.habits.add(habit);
                  });
                },
              ),
            ),
          );
        },
        backgroundColor: KnotHabitsTheme.primaryGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        child: const Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  SliverAppBar _buildHeader() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 90,
      backgroundColor: KnotHabitsTheme.background,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              10,
              20,
              8,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF09B981),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.link,
                    color: Colors.white,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Knot Habits',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color:
                              KnotHabitsTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'TODAY',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color:
                              KnotHabitsTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFD7CF),
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '🔥',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$_overallStreak',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFB83A20),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color:
                        KnotHabitsTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // STREAK CARD
  // ------------------------------------------------------------

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDDE3F8),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6CE),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '🔥',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$_overallStreak-Day Streak Alive',
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      '1.5x chain boost active',
                      style: TextStyle(
                        fontSize: 15,
                        color:
                            KnotHabitsTheme
                                .textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD6CE),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Text(
                  '$_overallStreakᴅ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFB83A20),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DAILY MOMENTUM',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color:
                      KnotHabitsTheme.textSecondary,
                ),
              ),
              Text(
                '${(_dailyProgress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color:
                      KnotHabitsTheme.primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: _dailyProgress,
              minHeight: 9,
              backgroundColor:
                  const Color(0xFFE0E5FA),
              color:
                  KnotHabitsTheme.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // WEEKLY CHAIN
  // ------------------------------------------------------------

  Widget _buildWeeklyChain() {
    final now = DateTime.now();

    final monday = now.subtract(
      Duration(days: now.weekday - 1),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFDDE3F8),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                'WEEKLY CHAIN',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              Text(
                _formatWeekRange(monday),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color:
                      KnotHabitsTheme.primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: List.generate(
              7,
              (index) {
                final date = monday.add(
                  Duration(days: index),
                );

                final isToday =
                    _isSameDay(date, now);

                final scheduled =
                    widget.habits.any(
                  (habit) =>
                      habit.isScheduledOn(date),
                );

                final completed =
                    scheduled &&
                        widget.habits
                            .where(
                              (habit) =>
                                  habit.isScheduledOn(
                                date,
                              ),
                            )
                            .every(
                              (habit) =>
                                  habit.isCompletedOn(
                                date,
                              ),
                            );

                return Column(
                  children: [
                    Text(
                      _dayLetter(index),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w800,
                        color: isToday
                            ? KnotHabitsTheme
                                .primaryGreen
                            : KnotHabitsTheme
                                .textSecondary,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: completed
                            ? KnotHabitsTheme
                                .primaryGreen
                            : isToday
                                ? const Color(
                                    0xFF20C997,
                                  )
                                : const Color(
                                    0xFFE9ECF8,
                                  ),
                        shape: BoxShape.circle,
                        border: isToday
                            ? Border.all(
                                color:
                                    KnotHabitsTheme
                                        .primaryGreen,
                                width: 2,
                              )
                            : null,
                      ),
                      child: Center(
                        child: completed
                            ? const Icon(
                                Icons.link,
                                size: 19,
                                color: Colors.white,
                              )
                            : isToday
                                ? const Icon(
                                    Icons.check,
                                    color:
                                        Colors.white,
                                  )
                                : const Icon(
                                    Icons
                                        .lock_outline,
                                    size: 17,
                                    color: Color(
                                      0xFF8E96AA,
                                    ),
                                  ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${date.day}',
                      style:
                          const TextStyle(
                        fontSize: 12,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _dayLetter(int index) {
    const days = [
      'M',
      'T',
      'W',
      'T',
      'F',
      'S',
      'S',
    ];

    return days[index];
  }

  String _formatWeekRange(DateTime monday) {
    final sunday =
        monday.add(const Duration(days: 6));

    return '${_monthName(monday.month)} ${monday.day} - '
        '${_monthName(sunday.month)} ${sunday.day}';
  }

  String _monthName(int month) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];

    return months[month - 1];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  // ------------------------------------------------------------
  // FILTERS
  // ------------------------------------------------------------

  Widget _buildFilters() {
    return Row(
      children: [
        _FilterChip(
          label: 'ALL (${_todayHabits.length})',
          selected: _filter == 'all',
          onTap: () {
            setState(() {
              _filter = 'all';
            });
          },
        ),

        const SizedBox(width: 8),

        _FilterChip(
          label:
              'PENDING (${_pendingToday.length})',
          selected: _filter == 'pending',
          onTap: () {
            setState(() {
              _filter = 'pending';
            });
          },
        ),

        const SizedBox(width: 8),

        _FilterChip(
          label:
              'COMPLETED (${_completedToday.length})',
          selected: _filter == 'completed',
          onTap: () {
            setState(() {
              _filter = 'completed';
            });
          },
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // EMPTY STATE
  // ------------------------------------------------------------

  Widget _buildEmptyState() {
    String title;

    if (_filter == 'completed') {
      title = 'No completed habits yet';
    } else if (_filter == 'pending') {
      title = 'All habits completed!';
    } else {
      title = 'No habits for today';
    }

    return Container(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDDE3F8),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 42,
            color:
                KnotHabitsTheme.primaryGreen,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
  // ------------------------------------------------------------
  // FREEZE CARD
  // ------------------------------------------------------------

// ============================================================
// FILTER CHIP
// ============================================================

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 11,
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            color: selected
                ? KnotHabitsTheme.primaryGreen
                : Colors.white,
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? KnotHabitsTheme.primaryGreen
                  : const Color(0xFFDDE3F8),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: selected
                  ? Colors.white
                  : KnotHabitsTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// HABIT CARD
// ============================================================

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.completed,
    required this.onToggle,
    required this.onTap,
  });

  final Habit habit;
  final bool completed;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  IconData _getIcon() {
    switch (habit.icon) {
      case 'run':
        return Icons.directions_run;

      case 'book':
        return Icons.menu_book;

      case 'water':
        return Icons.water_drop_outlined;

      case 'focus':
        return Icons.psychology;

      case 'shower':
        return Icons.shower;

      case 'journal':
        return Icons.edit_note;

      case 'fitness':
        return Icons.fitness_center;

      default:
        return Icons.check;
    }
  }

  Color _getColor() {
    try {
      return Color(
        int.parse(
          habit.colorHex.replaceFirst(
            '#',
            '0xFF',
          ),
        ),
      );
    } catch (_) {
      return const Color(0xFFE0E5FA);
    }
  }

  int _currentStreak() {
    int streak = 0;

    DateTime date = DateTime.now();

    while (habit.isCompletedOn(date)) {
      streak++;

      date = date.subtract(
        const Duration(days: 1),
      );
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final streak = _currentStreak();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: const Color(0xFFDDE3F8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: _getColor(),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                _getIcon(),
                color: const Color(0xFF344054),
                size: 27,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      _CategoryTag(
                        label: habit.category,
                      ),

                      const SizedBox(width: 7),

                      Text(
                        '⚡ ${streak}d',
                        style: const TextStyle(
                          fontSize: 13,
                          color: KnotHabitsTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 180,
                ),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: completed
                      ? KnotHabitsTheme.primaryGreen
                      : const Color(0xFFE4E8F8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  completed
                      ? Icons.link
                      : Icons.circle_outlined,
                  color: completed
                      ? Colors.white
                      : const Color(0xFF8D97A8),
                  size: 27,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// CATEGORY TAG
// ============================================================

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E5FF),
        borderRadius:
            BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: Color(0xFF4C54D9),
        ),
      ),
    );
  }
}