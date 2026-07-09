import 'package:flutter_test/flutter_test.dart';
import 'package:lab11_testing_debugging/models/task.dart';
import 'package:lab11_testing_debugging/repositories/task_repository.dart';

void main() {
  group('TaskRepository Tests', () {
    late TaskRepository repository;

    setUp(() {
      // Arrange for each test
      repository = TaskRepository();
    });

    test('addTask() should add a new task and notify listeners', () {
      // Arrange
      final task = Task(id: '1', title: 'New Task');
      var isNotified = false;
      repository.addListener(() {
        isNotified = true;
      });

      // Act
      repository.addTask(task);

      // Assert
      expect(repository.tasks.length, 1);
      expect(repository.tasks.first.id, '1');
      expect(repository.tasks.first.title, 'New Task');
      expect(isNotified, isTrue);
    });

    test('deleteTask() should remove the task with the given ID and notify listeners', () {
      // Arrange
      final task1 = Task(id: '1', title: 'Task 1');
      final task2 = Task(id: '2', title: 'Task 2');
      repository.addTask(task1);
      repository.addTask(task2);
      expect(repository.tasks.length, 2);

      var isNotified = false;
      repository.addListener(() {
        isNotified = true;
      });

      // Act
      repository.deleteTask('1');

      // Assert
      expect(repository.tasks.length, 1);
      expect(repository.tasks.any((task) => task.id == '1'), isFalse);
      expect(repository.tasks.any((task) => task.id == '2'), isTrue);
      expect(isNotified, isTrue);
    });

    test('updateTask() should update task title and notify listeners', () {
      // Arrange
      final task = Task(id: '1', title: 'Original Title');
      repository.addTask(task);

      var isNotified = false;
      repository.addListener(() {
        isNotified = true;
      });

      // Act
      repository.updateTask('1', 'Updated Title');

      // Assert
      expect(repository.tasks.first.title, 'Updated Title');
      expect(isNotified, isTrue);
    });
  });
}
