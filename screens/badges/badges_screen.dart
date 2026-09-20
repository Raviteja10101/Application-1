import 'package:flutter/material.dart';

import '../../models/habit.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({
    super.key,
    required this.habits,
  });

  final List<Habit> habits;

  @override
  Widget build(BuildContext context) {
    final badges = _buildBadges();

    final unlockedCount =
        badges.where((badge) => badge.unlocked).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FD),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                20,
                24,
                20,
                100,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildHeader(unlockedCount, badges.length),

                  const SizedBox(height: 24),

                  _buildProgress(
                    unlockedCount,
                    badges.length,
                  ),

                  const SizedBox(height: 24),

                  ...badges.map(
                    (badge) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 14,
                      ),
                      child: _BadgeCard(
                        badge: badge,
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
    int unlocked,
    int total,
  ) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFFFD6CE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              '🏆',
              style: TextStyle(
                fontSize: 27,
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
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF111827),
                ),
              ),

              const SizedBox(height: 3),

              Text(
                '$unlocked of $total unlocked',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgress(
    int unlocked,
    int total,
  ) {
    final progress =
        total == 0 ? 0.0 : unlocked / total;

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
              const Text(
                'BADGE PROGRESS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: Color(0xFF6B7280),
                ),
              ),

              const Spacer(),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF00865A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor:
                  const Color(0xFFE0E5FA),
              color:
                  const Color(0xFF00865A),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BADGES
  // ============================================================

  List<_BadgeData> _buildBadges() {
    final allCompletions =
        habits.fold<int>(
      0,
      (total, habit) =>
          total + habit.completedDates.length,
    );

    final bestStreak = _bestStreakAcrossHabits();

    final hasMorningCompletion =
        _hasCompletionBeforeHour(9);

    final hasNightCompletion =
        _hasCompletionAfterHour(21);

    return [
      _BadgeData(
        title: 'Genesis Link',
        description:
            'Complete a habit for the first time.',
        icon: '🔗',
        unlocked: allCompletions >= 1,
      ),

      _BadgeData(
        title: 'Unbreakable',
        description:
            'Reach a 7-day streak.',
        icon: '🔥',
        unlocked: bestStreak >= 7,
      ),

      _BadgeData(
        title: 'Early Bird',
        description:
            'Complete a habit before 9 AM.',
        icon: '🌅',
        unlocked: hasMorningCompletion,
      ),

      _BadgeData(
        title: 'Frost Shield',
        description:
            'Use a streak freeze.',
        icon: '❄️',
        unlocked: false,
      ),

      _BadgeData(
        title: 'Iron Will',
        description:
            'Reach a 14-day streak.',
        icon: '⚔️',
        unlocked: bestStreak >= 14,
      ),

      _BadgeData(
        title: 'Century Chain',
        description:
            'Reach a 100-day streak.',
        icon: '💯',
        unlocked: bestStreak >= 100,
      ),

      _BadgeData(
        title: 'Night Owl',
        description:
            'Complete a habit after 9 PM.',
        icon: '🌙',
        unlocked: hasNightCompletion,
      ),
    ];
  }

  // ============================================================
  // BEST STREAK
  // ============================================================

  int _bestStreakAcrossHabits() {
    int best = 0;

    for (final habit in habits) {
      final streak = _calculateBestStreak(habit);

      if (streak > best) {
        best = streak;
      }
    }

    return best;
  }

  int _calculateBestStreak(Habit habit) {
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
        final difference =
            date.difference(previous).inDays;

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

  // ============================================================
  // TIME BADGES
  // ============================================================

  bool _hasCompletionBeforeHour(int hour) {
    for (final habit in habits) {
      for (final dateString
          in habit.completedDates) {
        final date = _parseDate(dateString);

        if (date == null) {
          continue;
        }

        if (date.hour > 0 &&
            date.hour < hour) {
          return true;
        }
      }
    }

    return false;
  }

  bool _hasCompletionAfterHour(int hour) {
    for (final habit in habits) {
      for (final dateString
          in habit.completedDates) {
        final date = _parseDate(dateString);

        if (date == null) {
          continue;
        }

        if (date.hour >= hour) {
          return true;
        }
      }
    }

    return false;
  }

  DateTime? _parseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }
}

// ============================================================
// BADGE DATA
// ============================================================

class _BadgeData {
  const _BadgeData({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });

  final String title;
  final String description;
  final String icon;
  final bool unlocked;
}

// ============================================================
// BADGE CARD
// ============================================================

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({
    required this.badge,
  });

  final _BadgeData badge;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(
        milliseconds: 200,
      ),
      opacity: badge.unlocked ? 1 : 0.55,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: badge.unlocked
                ? const Color(0xFFDDE3F8)
                : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: badge.unlocked
                    ? const Color(0xFFFFD6CE)
                    : const Color(0xFFE5E7EB),
                borderRadius:
                    BorderRadius.circular(17),
              ),
              child: Center(
                child: Text(
                  badge.unlocked
                      ? badge.icon
                      : '🔒',
                  style: const TextStyle(
                    fontSize: 27,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    badge.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    badge.description,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),

            if (badge.unlocked)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF00865A),
                size: 23,
              ),
          ],
        ),
      ),
    );
  }
}