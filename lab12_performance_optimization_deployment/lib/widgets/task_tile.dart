import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../screens/task_detail_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;

  const TaskTile({
    required ValueKey<String> key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Access the provider without listening, to trigger actions.
    final provider = Provider.of<TaskProvider>(context, listen: false);

    return Container(
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
                builder: (context) => TaskDetailScreen(taskId: task.id),
              ),
            );
          },
          leading: GestureDetector(
            key: Key('checkbox_${task.id}'),
            onTap: () => provider.toggleTask(task.id),
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
              color: task.completed ? Colors.white38 : Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            key: Key('delete_${task.id}'),
            icon: const Icon(
              Icons.delete_outline,
              color: Color(0xFFEF4444),
            ),
            onPressed: () => provider.deleteTask(task.id),
          ),
        ),
      ),
    );
  }
}
