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

  testWidgets('Full flow integration test: add, navigate, edit, save, and verify updates', (WidgetTester tester) async {
    // Arrange
    final repository = TaskRepository();
    await tester.pumpWidget(createTestWidget(repository));

    // 1. Act - Add "Original title"
    final textFieldFinder = find.byKey(const Key('taskTextField'));
    await tester.enterText(textFieldFinder, 'Original title');
    
    final addButtonFinder = find.byKey(const Key('addTaskButton'));
    await tester.tap(addButtonFinder);
    await tester.pump();

    // Verify task is added
    expect(find.text('Original title'), findsOneWidget);

    // 2. Act - Tap task -> open detail
    await tester.tap(find.text('Original title'));
    await tester.pumpAndSettle();

    // Verify detail screen is open
    expect(find.text('Task Detail'), findsOneWidget);
    
    // 3. Act - Edit -> "Updated title"
    final detailTitleFieldFinder = find.byKey(const Key('detailTitleField'));
    expect(detailTitleFieldFinder, findsOneWidget);
    await tester.enterText(detailTitleFieldFinder, 'Updated title');

    // 4. Act - Save
    final saveButtonFinder = find.byKey(const Key('saveButton'));
    expect(saveButtonFinder, findsOneWidget);
    await tester.tap(saveButtonFinder);
    await tester.pumpAndSettle(); // Settle transition back to TaskListScreen

    // 5. Assert - Verify updated title appears in list and original title is gone
    expect(find.text('Updated title'), findsOneWidget);
    expect(find.text('Original title'), findsNothing);
  });
}
