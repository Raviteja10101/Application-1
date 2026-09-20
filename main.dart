import 'package:flutter/material.dart';

import 'app/app.dart';
import 'services/habit_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HabitStorage.init();

  runApp(const KnotHabitsApp());
}