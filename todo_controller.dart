import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/todo.dart';

enum TodoFilter { all, active, completed }

class TodoController extends GetxController {
  final todos = <Todo>[].obs;
  final storage = GetStorage();
  final filter = TodoFilter.all.obs;
  final isDarkMode = false.obs;
  final searchQuery = ''.obs;
  final currentIndex = 0.obs;

  final draftCategory = TodoCategory.other.obs;
  final draftPriority = TodoPriority.medium.obs;
  final draftDate = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    isDarkMode.value = storage.read('isDarkMode') ?? false;
    
    List? storedTodos = storage.read<List>('todos');
    if (storedTodos != null) {
      todos.assignAll(storedTodos.map((e) => Todo.fromJson(e)).toList());
    }
    
    ever(todos, (_) {
      storage.write('todos', todos.map((e) => e.toJson()).toList());
    });
  }

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    storage.write('isDarkMode', isDarkMode.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    HapticFeedback.mediumImpact();
  }

  List<Todo> get filteredTodos {
    List<Todo> list = todos.toList();
    if (searchQuery.value.isNotEmpty) {
      list = list.where((t) => t.title.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    if (filter.value == TodoFilter.active) {
      list = list.where((t) => !t.isDone).toList();
    } else if (filter.value == TodoFilter.completed) {
      list = list.where((t) => t.isDone).toList();
    }
    
    list.sort((a, b) {
      if (a.isDone != b.isDone) return a.isDone ? 1 : -1;
      if (a.priority != b.priority) return b.priority.index.compareTo(a.priority.index);
      return (a.dueDate ?? DateTime(3000)).compareTo(b.dueDate ?? DateTime(3000));
    });
    return list;
  }

  // Statistics getters
  int get totalCount => todos.length;
  int get completedCount => todos.where((t) => t.isDone).length;
  int get activeCount => totalCount - completedCount;
  double get progressPercentage => totalCount == 0 ? 0.0 : completedCount / totalCount;

  Map<TodoCategory, int> get categoryStats {
    final stats = <TodoCategory, int>{};
    for (var cat in TodoCategory.values) {
      stats[cat] = todos.where((t) => t.category == cat).length;
    }
    return stats;
  }

  Map<TodoPriority, int> get priorityStats {
    final stats = <TodoPriority, int>{};
    for (var prio in TodoPriority.values) {
      stats[prio] = todos.where((t) => t.priority == prio).length;
    }
    return stats;
  }

  // --- Actions with Feedback ---
  void addTodo(String title) {
    if (title.trim().isNotEmpty) {
      todos.add(Todo(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.trim(),
        category: draftCategory.value,
        priority: draftPriority.value,
        dueDate: draftDate.value,
      ));
      
      Get.snackbar(
        'Task Added',
        '\"${title.trim()}\" is now on your list.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
        backgroundColor: Get.theme.colorScheme.primaryContainer,
        colorText: Get.theme.colorScheme.onPrimaryContainer,
      );
      
      HapticFeedback.mediumImpact();
      draftCategory.value = TodoCategory.other;
      draftPriority.value = TodoPriority.medium;
      draftDate.value = null;
    }
  }

  void toggleTodo(Todo todo) {
    todo.isDone = !todo.isDone;
    todos.refresh();
    if (todo.isDone) {
      HapticFeedback.lightImpact();
    }
  }

  void editTodo(Todo todo, String title, TodoCategory cat, TodoPriority prio, DateTime? date) {
    if (title.trim().isNotEmpty) {
      todo.title = title.trim();
      todo.category = cat;
      todo.priority = prio;
      todo.dueDate = date;
      todos.refresh();
    }
  }

  void removeTodo(Todo todo) {
    todos.remove(todo);
    HapticFeedback.mediumImpact();
    Get.rawSnackbar(
      message: 'Task deleted',
      mainButton: TextButton(
        onPressed: () {
          todos.add(todo);
          if (Get.isSnackbarOpen) Get.back();
        },
        child: const Text('UNDO', style: TextStyle(color: Colors.amber)),
      ),
    );
  }

  void clearCompleted() {
    int count = todos.where((t) => t.isDone).length;
    if (count > 0) {
      todos.removeWhere((todo) => todo.isDone);
      HapticFeedback.heavyImpact();
      Get.snackbar('Clean Slate!', 'Removed $count completed tasks.');
    }
  }
}
