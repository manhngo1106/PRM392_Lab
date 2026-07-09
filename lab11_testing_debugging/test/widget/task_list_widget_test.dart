import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  group('TaskListScreen Widget Tests', () {
    late TaskRepository repository;

    setUp(() {
      repository = TaskRepository();
    });

    testWidgets('should display empty state text when there are no tasks', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestWidget(repository));

      // Assert
      expect(find.text('No tasks yet. Add one!'), findsOneWidget);
    });

    testWidgets('should add a task when text is entered and Add is tapped', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(repository));

      // Act
      final textFieldFinder = find.byKey(const Key('taskTextField'));
      await tester.enterText(textFieldFinder, 'My First Task');

      final addButtonFinder = find.byKey(const Key('addTaskButton'));
      await tester.tap(addButtonFinder);
      await tester.pump();

      // Assert
      expect(find.text('My First Task'), findsOneWidget);
      expect(find.text('No tasks yet. Add one!'), findsNothing);
    });

    testWidgets('should display multiple tasks when added', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(repository));
      final textFieldFinder = find.byKey(const Key('taskTextField'));
      final addButtonFinder = find.byKey(const Key('addTaskButton'));

      // Act - Add task 1
      await tester.enterText(textFieldFinder, 'Task 1');
      await tester.tap(addButtonFinder);
      await tester.pump();

      // Act - Add task 2
      await tester.enterText(textFieldFinder, 'Task 2');
      await tester.tap(addButtonFinder);
      await tester.pump();

      // Assert
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });
  });
}
