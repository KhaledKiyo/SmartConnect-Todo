import 'package:flutter/material.dart';

enum TodoPriority {
  low(Icons.keyboard_arrow_down_rounded, Colors.blue),
  medium(Icons.menu_rounded, Colors.orange),
  high(Icons.keyboard_double_arrow_up_rounded, Colors.red);

  final IconData icon;
  final Color color;
  const TodoPriority(this.icon, this.color);
}

enum TodoCategory {
  personal(Icons.person_rounded, Colors.blue),
  work(Icons.work_rounded, Colors.orange),
  shopping(Icons.shopping_cart_rounded, Colors.green),
  other(Icons.more_horiz_rounded, Colors.grey);

  final IconData icon;
  final Color color;
  const TodoCategory(this.icon, this.color);
}

class Todo {
  String id;
  String title;
  bool isDone;
  TodoCategory category;
  TodoPriority priority;
  DateTime? dueDate;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    this.category = TodoCategory.other,
    this.priority = TodoPriority.medium,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isDone': isDone,
        'category': category.name,
        'priority': priority.name,
        'dueDate': dueDate?.toIso8601String(),
      };

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'],
        title: json['title'],
        isDone: json['isDone'],
        category: TodoCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => TodoCategory.other,
        ),
        priority: TodoPriority.values.firstWhere(
          (e) => e.name == (json['priority'] ?? 'medium'),
          orElse: () => TodoPriority.medium,
        ),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      );
}
