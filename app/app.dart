import 'package:flutter/material.dart';

import 'theme.dart';
import '../data/habit_data.dart';
import '../models/habit.dart';
import '../screens/today/today_screen.dart';
import '../services/habit_storage.dart';
import '../screens/badges/badges_screen.dart';
import '../screens/settings/settings_screen.dart';

class KnotHabitsApp extends StatefulWidget {
  const KnotHabitsApp({super.key});

  @override
  State<KnotHabitsApp> createState() => _KnotHabitsAppState();
}

class _KnotHabitsAppState extends State<KnotHabitsApp> {
  late final List<Habit> habits;

  @override
  void initState() {
    super.initState();

    if (HabitStorage.hasHabits) {
      habits = HabitStorage.loadHabits();
    } else {
      habits = sampleHabits;

      HabitStorage.saveHabits(habits);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Knot Habits',
      debugShowCheckedModeBanner: false,
      theme: KnotHabitsTheme.light,
      home: AppShell(
  habits: habits,
),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({
    super.key,
    required this.habits,
  });

  final List<Habit> habits;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 1;

late final List<Widget> _screens;

@override
void initState() {
  super.initState();

_screens = [
  BadgesScreen(
    habits: widget.habits,
  ),
  TodayScreen(
    habits: widget.habits,
  ),
  const SettingsScreen(),
];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Badges',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}