import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_testing_debugging/models/task.dart';
import 'package:lab11_testing_debugging/repositories/task_repository.dart';
import 'package:lab11_testing_debugging/repositories/task_repository_provider.dart';
import 'package:lab11_testing_debugging/screens/task_list_screen.dart';

void main() {
  Widget createTestWidget(TaskRepository repository) {
    return TaskRepositoryProvider(
      notifier: repository,
      child: const MaterialApp(
        home: TaskListScreen(),
      ),
    );
  }

  testWidgets('should navigate to TaskDetailScreen when a task is tapped', (WidgetTester tester) async {
    // Arrange - Seed repository with at least one task
    final repository = TaskRepository();
    final task = Task(id: '123', title: 'Seeded Task');
    repository.addTask(task);

    // Act - Pump TaskListScreen
    await tester.pumpWidget(createTestWidget(repository));

    // Act - Tap seeded task -> call pumpAndSettle()
    await tester.tap(find.text('Seeded Task'));
    await tester.pumpAndSettle();

    // Assert - Validate AppBar title: "Task Detail"
    expect(find.text('Task Detail'), findsOneWidget);

    // Assert - Validate TextField key: detailTitleField
    final textFieldFinder = find.byKey(const Key('detailTitleField'));
    expect(textFieldFinder, findsOneWidget);

    final TextField textField = tester.widget<TextField>(textFieldFinder);
    expect(textField.controller?.text, 'Seeded Task');
  });
}
