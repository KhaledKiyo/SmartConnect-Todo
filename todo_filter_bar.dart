import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/todo_controller.dart';

class TodoFilterBar extends StatelessWidget {
  final TodoController controller;

  const TodoFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() => Row(
            children: [
              _filterChip('All', TodoFilter.all),
              _filterChip('Active', TodoFilter.active),
              _filterChip('Done', TodoFilter.completed),
            ],
          )),
    );
  }

  Widget _filterChip(String label, TodoFilter f) {
    final isSelected = controller.filter.value == f;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.filter.value = f,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
      ),
    );
  }
}
