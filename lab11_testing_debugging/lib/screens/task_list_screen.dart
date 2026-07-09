import 'package:flutter/material.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../repositories/task_repository_provider.dart';
import 'task_detail_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask(TaskRepository repository) {
    final title = _taskController.text.trim();
    if (title.isNotEmpty) {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
      );
      repository.addTask(task);
      _taskController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final repository = TaskRepositoryProvider.of(context);
    final tasks = repository.tasks;
    final completedCount = tasks.where((t) => t.completed).length;

    return Scaffold(
      backgroundColor: const Color(0xFF12121A),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header with Gradient
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32.0),
                  bottomRight: Radius.circular(32.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Taskly',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Text(
                          '$completedCount/${tasks.length} Done',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Stay organized, achieve your goals.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ),

            // Task List or Empty State
            Expanded(
              child: tasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.playlist_add_check,
                            size: 80.0,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'No tasks yet. Add one!',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Container(
                          key: Key('task_item_${task.id}'),
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: Material(
                            color: const Color(0xFF1E1E2E),
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              side: BorderSide(
                                color: task.completed
                                    ? const Color(0xFF6366F1).withOpacity(0.3)
                                    : Colors.white.withOpacity(0.05),
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 4.0),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TaskRepositoryProvider(
                                      notifier: repository,
                                      child: TaskDetailScreen(taskId: task.id),
                                    ),
                                  ),
                                );
                              },
                              leading: GestureDetector(
                                key: Key('checkbox_${task.id}'),
                                onTap: () => repository.toggleTask(task.id),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: task.completed
                                        ? const Color(0xFF6366F1)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: task.completed
                                          ? const Color(0xFF6366F1)
                                          : Colors.white54,
                                      width: 2.0,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4.0),
                                  child: task.completed
                                      ? const Icon(
                                          Icons.check,
                                          size: 16.0,
                                          color: Colors.white,
                                        )
                                      : const SizedBox(
                                          width: 16.0,
                                          height: 16.0,
                                        ),
                                ),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  color: task.completed
                                      ? Colors.white38
                                      : Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  decoration: task.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              trailing: IconButton(
                                key: Key('delete_${task.id}'),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Color(0xFFEF4444),
                                ),
                                onPressed: () => repository.deleteTask(task.id),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: TextField(
                  key: const Key('taskTextField'),
                  controller: _taskController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Enter new task...',
                    hintStyle: TextStyle(color: Colors.white30),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            ElevatedButton(
              key: const Key('addTaskButton'),
              onPressed: () => _addTask(repository),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 20.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
