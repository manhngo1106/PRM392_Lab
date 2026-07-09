# Lab 11.5 - Test Suite Summary Document
**Module 11: Testing & Debugging in Flutter**
**Project:** Taskly App

---

## 1. Test Suite Summary
The Taskly test suite contains a total of **11 tests** across four distinct testing categories, achieving **100% pass rates** across all runs.

### 1.1 Test Statistics
*   **Total Tests Executed:** 11
*   **Tests Passed:** 11
*   **Tests Failed:** 0
*   **Pass Rate:** 100%
*   **Execution Time:** ~3.5 seconds (automated suite)

---

## 2. Test Classifications & Behaviors Validated

### 2.1 Unit Tests (5 Tests)
*   **Location:** [test/unit/](file:///d:/FPT/PRM392/Lab/lab11_testing_debugging/test/unit/)
*   **Files:**
    *   [task_model_test.dart](file:///d:/FPT/PRM392/Lab/lab11_testing_debugging/test/unit/task_model_test.dart)
    *   [task_repository_test.dart](file:///d:/FPT/PRM392/Lab/lab11_testing_debugging/test/unit/task_repository_test.dart)
*   **Behaviors Validated:**
    *   `Task` model instantiation with a default `completed` status of `false`.
    *   `Task.toggle()` switches status between `true` and `false` and back.
    *   `TaskRepository.addTask()` adds a task, increases list length, and notifies UI listeners.
    *   `TaskRepository.deleteTask()` removes the task by its ID and notifies listeners.
    *   `TaskRepository.updateTask()` correctly updates the task title and notifies listeners.

### 2.2 Widget Tests (3 Tests)
*   **Location:** [test/widget/](file:///d:/FPT/PRM392/Lab/lab11_testing_debugging/test/widget/)
*   **File:** [task_list_widget_test.dart](file:///d:/FPT/PRM392/Lab/lab11_testing_debugging/test/widget/task_list_widget_test.dart)
*   **Behaviors Validated:**
    *   **Empty State:** Displays `"No tasks yet. Add one!"` text when the task list is empty.
    *   **Task Addition:** Verifies entering text, tapping `"Add"`, and asserting the title appears on screen and that the empty state is removed.
    *   **Multiple Tasks:** Adds multiple tasks and ensures they are both rendered in the list view.

### 2.3 Navigation Tests (1 Test)
*   **Location:** [test/widget/](file:///d:/FPT/PRM392/Lab/lab11_testing_debugging/test/widget/)
*   **File:** [task_navigation_test.dart](file:///d:/FPT/PRM392/Lab/lab11_testing_debugging/test/widget/task_navigation_test.dart)
*   **Behaviors Validated:**
    *   Transition from the Task List Screen to the Task Detail Screen upon tapping a list tile.
    *   Loads the detail page with the correct task title.
    *   Ensures the presence of the AppBar with title `"Task Detail"` and the detail text field with key `detailTitleField`.

### 2.4 Integration Tests (2 Tests)
*   **Locations:** 
    *   [test/widget/task_integration_test.dart](file:///d:/FPT/PRM392/Lab/lab11_testing_debugging/test/widget/task_integration_test.dart)
    *   [test/integration/task_integration_test.dart](file:///d:/FPT/PRM392/Lab/lab11_testing_debugging/test/integration/task_integration_test.dart)
*   **Behaviors Validated:**
    *   Verifies the full end-to-end application lifecycle:
        1.  Adds a task with an `"Original title"`.
        2.  Navigates to the details screen for that task.
        3.  Updates the title to `"Updated title"`.
        4.  Saves the changes and returns.
        5.  Asserts that `"Updated title"` replaces the `"Original title"` on the home screen.

---

## 3. Known Limitations & Recommendations

1.  **Ephemeral In-Memory State:**
    *   **Limitation:** The repository state is stored purely in memory. A hot restart or app termination resets the state.
    *   **Recommendation:** Integrate a local database (SQLite, Drift, or Hive) and write unit tests mocking the database adapter.
2.  **No Network Integration:**
    *   **Limitation:** The app runs entirely offline, meaning sync issues, caching, or network latency are not covered by current integration tests.
    *   **Recommendation:** Use HTTP client mocking (`nock` or mockito) to test network boundaries.
3.  **Basic Keyboard/Focus Verification:**
    *   **Limitation:** The tests focus on text changes and click events, but do not test keyboard layout shifts or focus transfers.
    *   **Recommendation:** Implement focus node assertion tests in future widget updates.
