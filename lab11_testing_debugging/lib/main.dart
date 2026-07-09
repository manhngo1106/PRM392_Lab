import 'package:flutter/material.dart';
import 'repositories/task_repository.dart';
import 'repositories/task_repository_provider.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final taskRepository = TaskRepository();

    return TaskRepositoryProvider(
      notifier: taskRepository,
      child: MaterialApp(
        title: 'Taskly',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6366F1),
            brightness: Brightness.dark,
          ),
          fontFamily: 'Roboto',
        ),
        debugShowCheckedModeBanner: false,
        home: const TaskListScreen(),
      ),
    );
  }
}
