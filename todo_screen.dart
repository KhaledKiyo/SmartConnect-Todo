import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';
import 'widgets/todo_item.dart';
import 'widgets/add_task_sheet.dart';
import 'widgets/todo_filter_bar.dart';

class TodoScreen extends StatelessWidget {
  final TodoController controller = Get.find<TodoController>();
  final TextEditingController textController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Tasks', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              Obx(() => IconButton(
                    icon: Icon(controller.isDarkMode.value ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                    onPressed: () => controller.toggleTheme(),
                  )),
              _buildMoreMenu(),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) => controller.searchQuery.value = val,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: TodoFilterBar(controller: controller),
          ),
          Obx(() {
            final items = controller.filteredTodos;
            if (items.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt_rounded, size: 80, color: theme.colorScheme.primary.withValues(alpha: 0.1)),
                      const SizedBox(height: 16),
                      Text(controller.searchQuery.isEmpty ? 'All caught up' : 'No matches found', 
                           style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline)),
                    ],
                  ),
                ),
              );
            }
            return SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TodoItem(
                    todo: items[index],
                    onToggle: () => controller.toggleTodo(items[index]),
                    onDelete: () => controller.removeTodo(items[index]),
                    onEdit: (title, cat, prio, date) => controller.editTodo(items[index], title, cat, prio, date),
                  ),
                  childCount: items.length,
                ),
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
        elevation: 4,
      ),
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert_rounded),
      itemBuilder: (context) => [
        PopupMenuItem(
          onTap: () => controller.clearCompleted(),
          child: const Row(
            children: [
              Icon(Icons.delete_sweep_rounded, size: 20),
              SizedBox(width: 12),
              Text('Clear Completed'),
            ],
          ),
        ),
      ],
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    textController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskSheet(
        controller: controller,
        textController: textController,
      ),
    );
  }
}
