import 'package:flutter/material.dart';
import 'task_repository.dart';

class TaskRepositoryProvider extends InheritedNotifier<TaskRepository> {
  const TaskRepositoryProvider({
    super.key,
    required TaskRepository super.notifier,
    required super.child,
  });

  static TaskRepository of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<TaskRepositoryProvider>();
    assert(provider != null, 'No TaskRepositoryProvider found in context');
    return provider!.notifier!;
  }
}
