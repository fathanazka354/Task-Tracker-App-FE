import 'package:flutter/material.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/task_list_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const TaskTrackerApp());
}

class TaskTrackerApp extends StatelessWidget {
  const TaskTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const TaskListPage(),
    );
  }
}
