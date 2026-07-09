import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:lab12_performance_optimization_deployment/main.dart';

void main() {
  testWidgets('Taskly flow: add, toggle, and delete a task', (WidgetTester tester) async {
    // Build the application
    await tester.pumpWidget(const MyApp());

    // 1. Verify we start with the empty state
    expect(find.text('No tasks yet. Add one!'), findsOneWidget);
    expect(find.text('0/0 Done'), findsOneWidget);

    // 2. Add a new task
    final textField = find.byKey(const Key('taskTextField'));
    expect(textField, findsOneWidget);
    await tester.enterText(textField, 'Learn Performance Optimization');
    await tester.pump();

    final addButton = find.byKey(const Key('addTaskButton'));
    expect(addButton, findsOneWidget);
    await tester.tap(addButton);
    await tester.pumpAndSettle();

    // Verify the task was added
    expect(find.text('Learn Performance Optimization'), findsOneWidget);
    expect(find.text('0/1 Done'), findsOneWidget);

    // 3. Toggle completion
    final checkboxFinder = find.byWidgetPredicate(
      (widget) => widget is GestureDetector && 
                  widget.key != null && 
                  widget.key.toString().contains('checkbox_')
    );
    expect(checkboxFinder, findsOneWidget);
    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    // Verify it is completed
    expect(find.text('1/1 Done'), findsOneWidget);

    // 4. Delete the task
    final deleteButtonFinder = find.byWidgetPredicate(
      (widget) => widget is IconButton &&
                  widget.key != null &&
                  widget.key.toString().contains('delete_')
    );
    expect(deleteButtonFinder, findsOneWidget);
    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    // Verify it returns to empty state
    expect(find.text('No tasks yet. Add one!'), findsOneWidget);
    expect(find.text('0/0 Done'), findsOneWidget);
  });
}
