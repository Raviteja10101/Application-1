import 'package:flutter/material.dart';

import '../../models/habit.dart';
import '../../services/habit_storage.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({
    super.key,
    this.habit,
    this.onHabitCreated,
    this.onHabitUpdated,
  });

  final Habit? habit;

  final ValueChanged<Habit>? onHabitCreated;
  final ValueChanged<Habit>? onHabitUpdated;

  bool get isEditing => habit != null;

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  late final TextEditingController _nameController;

  String _category = 'HEALTH';
  String _icon = 'run';

  HabitScheduleType _scheduleType = HabitScheduleType.daily;

  final Set<int> _selectedDays = {};

  bool _reminderEnabled = false;
  TimeOfDay _reminderTime = const TimeOfDay(
    hour: 8,
    minute: 0,
  );

  final List<String> _categories = [
    'HEALTH',
    'MIND',
    'FOCUS',
    'DISCIPLINE',
    'REFLECTION',
    'VITALITY',
  ];

  final List<_IconOption> _icons = const [
    _IconOption(
      name: 'run',
      icon: Icons.directions_run,
    ),
    _IconOption(
      name: 'book',
      icon: Icons.menu_book,
    ),
    _IconOption(
      name: 'water',
      icon: Icons.water_drop,
    ),
    _IconOption(
      name: 'focus',
      icon: Icons.center_focus_strong,
    ),
    _IconOption(
      name: 'shower',
      icon: Icons.shower,
    ),
    _IconOption(
      name: 'journal',
      icon: Icons.edit_note,
    ),
    _IconOption(
      name: 'fitness',
      icon: Icons.fitness_center,
    ),
    _IconOption(
      name: 'sleep',
      icon: Icons.bedtime,
    ),
    _IconOption(
      name: 'food',
      icon: Icons.restaurant,
    ),
  ];

  final List<String> _dayLabels = [
    'M',
    'T',
    'W',
    'T',
    'F',
    'S',
    'S',
  ];

  @override
  void initState() {
    super.initState();

    final habit = widget.habit;

    _nameController = TextEditingController(
      text: habit?.name ?? '',
    );

    if (habit != null) {
      _category = habit.category;
      _icon = habit.icon;
      _scheduleType = habit.scheduleType;
      _selectedDays.addAll(habit.activeDays);
      _reminderEnabled = habit.reminderEnabled;

      if (habit.reminderTime != null) {
        final parts = habit.reminderTime!.split(':');

        if (parts.length == 2) {
          _reminderTime = TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 8,
            minute: int.tryParse(parts[1]) ?? 0,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FD),
      appBar: AppBar(
        title: Text(
          isEditing ? 'Edit Habit' : 'New Habit',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: const Color(0xFFF7F7FD),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            30,
          ),
          children: [
            // ====================================================
            // NAME
            // ====================================================

            const Text(
              'HABIT NAME',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'e.g. Read 20 pages',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFDDE3F8),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFFDDE3F8),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF00865A),
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // CATEGORY
            // ====================================================

            const Text(
              'CATEGORY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final selected = _category == category;

                return ChoiceChip(
                  label: Text(category),
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _category = category;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // ICON
            // ====================================================

            const Text(
              'ICON',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 10),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _icons.map((option) {
                final selected = _icon == option.name;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _icon = option.name;
                    });
                  },
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFE9EBFF)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selected
                            ? const Color(0xFF515BE8)
                            : const Color(0xFFDDE3F8),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Icon(
                      option.icon,
                      color: selected
                          ? const Color(0xFF515BE8)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // SCHEDULE
            // ====================================================

            const Text(
              'SCHEDULE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _ScheduleOption(
                    title: 'Every day',
                    selected:
                        _scheduleType == HabitScheduleType.daily,
                    onTap: () {
                      setState(() {
                        _scheduleType =
                            HabitScheduleType.daily;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ScheduleOption(
                    title: 'Specific days',
                    selected:
                        _scheduleType ==
                            HabitScheduleType.specificDays,
                    onTap: () {
                      setState(() {
                        _scheduleType =
                            HabitScheduleType.specificDays;
                      });
                    },
                  ),
                ),
              ],
            ),

            if (_scheduleType ==
                HabitScheduleType.specificDays) ...[
              const SizedBox(height: 15),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final selected =
                      _selectedDays.contains(day);

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selected) {
                          _selectedDays.remove(day);
                        } else {
                          _selectedDays.add(day);
                        }
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF00865A)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF00865A)
                              : const Color(0xFFDDE3F8),
                        ),
                      ),
                      child: Text(
                        _dayLabels[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],

            const SizedBox(height: 25),

            // ====================================================
            // REMINDER
            // ====================================================

            const Text(
              'REMINDER',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFDDE3F8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.notifications_none,
                    color: Color(0xFF515BE8),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      'Daily reminder',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Switch(
                    value: _reminderEnabled,
                    onChanged: (value) {
                      setState(() {
                        _reminderEnabled = value;
                      });
                    },
                    activeThumbColor: Colors.white,
                    activeTrackColor:
                        const Color(0xFF00865A),
                  ),
                ],
              ),
            ),

            if (_reminderEnabled) ...[
              const SizedBox(height: 10),

              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFDDE3F8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        color: Color(0xFF515BE8),
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Reminder time',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      Text(
                        _reminderTime.format(context),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF00865A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 35),

            // ====================================================
            // SAVE
            // ====================================================

            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00865A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(17),
                  ),
                ),
                child: Text(
                  isEditing ? 'Save Changes' : 'Create Habit',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIME PICKER
  // ============================================================

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _saveHabit() async {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a habit name.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_scheduleType == HabitScheduleType.specificDays &&
        _selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one day.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final existingHabit = widget.habit;

    final habit = Habit(
      id: existingHabit?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      category: _category,
      icon: _icon,
      colorHex: existingHabit?.colorHex ?? '#DDE2FF',
      scheduleType: _scheduleType,
      activeDays: _scheduleType ==
              HabitScheduleType.specificDays
          ? _selectedDays.toList()
          : [],
      reminderEnabled: _reminderEnabled,
      reminderTime: _reminderEnabled
          ? '${_reminderTime.hour.toString().padLeft(2, '0')}:'
              '${_reminderTime.minute.toString().padLeft(2, '0')}'
          : null,

      // IMPORTANT:
      // Keep all previous completion history when editing.
      completedDates:
          existingHabit?.completedDates ?? [],

      // Keep original creation date when editing.
      createdAt:
          existingHabit?.createdAt ?? DateTime.now(),
    );

    await HabitStorage.saveHabit(habit);

    if (!mounted) return;

    if (existingHabit != null) {
      widget.onHabitUpdated?.call(habit);
    } else {
      widget.onHabitCreated?.call(habit);
    }

    Navigator.pop(context, habit);
  }
}

// ================================================================
// SCHEDULE OPTION
// ================================================================

class _ScheduleOption extends StatelessWidget {
  const _ScheduleOption({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
          horizontal: 12,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE9EBFF)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? const Color(0xFF515BE8)
                : const Color(0xFFDDE3F8),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected
                ? const Color(0xFF515BE8)
                : const Color(0xFF374151),
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ICON OPTION
// ================================================================

class _IconOption {
  const _IconOption({
    required this.name,
    required this.icon,
  });

  final String name;
  final IconData icon;
}