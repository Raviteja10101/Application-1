import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/habit.dart';

class HabitStorage {
  static const String _boxName = 'habits';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _box => Hive.box<String>(_boxName);

  static Future<void> saveHabit(Habit habit) async {
    await _box.put(
      habit.id,
      jsonEncode(habit.toJson()),
    );
  }

  static Future<void> saveHabits(List<Habit> habits) async {
    for (final habit in habits) {
      await saveHabit(habit);
    }
  }

  static List<Habit> loadHabits() {
    return _box.values.map((value) {
      final json = jsonDecode(value) as Map<String, dynamic>;
      return Habit.fromJson(json);
    }).toList();
  }

  static Future<void> deleteHabit(String id) async {
    await _box.delete(id);
  }

  static bool get hasHabits => _box.isNotEmpty;
}