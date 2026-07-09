import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_testing_debugging/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test('should have completed as false by default', () {
      // Arrange
      const String taskId = '1';
      const String taskTitle = 'Test Task';

      // Act
      final task = Task(id: taskId, title: taskTitle);

      // Assert
      expect(task.id, taskId);
      expect(task.title, taskTitle);
      expect(task.completed, isFalse);
    });

    test('toggle() should switch completed status from false to true and back', () {
      // Arrange
      final task = Task(id: '1', title: 'Test Task');
      expect(task.completed, isFalse);

      // Act - First Toggle (false -> true)
      task.toggle();

      // Assert
      expect(task.completed, isTrue);

      // Act - Second Toggle (true -> false)
      task.toggle();

      // Assert
      expect(task.completed, isFalse);
    });
  });
}
