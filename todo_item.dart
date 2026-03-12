import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../models/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final Function(String, TodoCategory, TodoPriority, DateTime?) onEdit;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: Key(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
      ),
      onDismissed: (_) {
        HapticFeedback.mediumImpact();
        onDelete();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            onToggle();
          },
          onLongPress: () {
            HapticFeedback.heavyImpact();
            _showEditDialog(context);
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildPriorityIndicator(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          decoration: todo.isDone ? TextDecoration.lineThrough : null,
                          color: todo.isDone ? theme.colorScheme.outline : theme.colorScheme.onSurface,
                          fontWeight: todo.isDone ? FontWeight.normal : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildTag(todo.category.icon, todo.category.name.capitalizeFirst!, todo.category.color),
                          if (todo.dueDate != null) ...[
                            const SizedBox(width: 8),
                            _buildTag(Icons.calendar_today_rounded, DateFormat('MMM d').format(todo.dueDate!), theme.colorScheme.outline),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_note_rounded, color: theme.colorScheme.primary.withValues(alpha: 0.7)),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _showEditDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator() {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: todo.isDone ? Colors.grey.withValues(alpha: 0.2) : todo.priority.color.withValues(alpha: 0.15),
        border: Border.all(
          color: todo.isDone ? Colors.grey.withValues(alpha: 0.5) : todo.priority.color,
          width: 2,
        ),
      ),
      child: Center(
        child: todo.isDone 
          ? const Icon(Icons.check, size: 16, color: Colors.grey)
          : Icon(todo.priority.icon, size: 16, color: todo.priority.color),
      ),
    );
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: todo.title);
    var selectedCategory = todo.category.obs;
    var selectedPriority = todo.priority.obs;
    var selectedDate = todo.dueDate.obs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Edit Task', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Task title',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Obx(() => ActionChip(
                  avatar: Icon(selectedCategory.value.icon, size: 18),
                  label: Text(selectedCategory.value.name.capitalizeFirst!),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _pickCategory(context, selectedCategory);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                )),
                Obx(() => ActionChip(
                  avatar: Icon(selectedPriority.value.icon, size: 18, color: selectedPriority.value.color),
                  label: Text(selectedPriority.value.name.capitalizeFirst!),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    _pickPriority(context, selectedPriority);
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                )),
                Obx(() => ActionChip(
                  avatar: const Icon(Icons.calendar_today_rounded, size: 18),
                  label: Text(selectedDate.value == null
                      ? 'Set Date'
                      : DateFormat('MMM d').format(selectedDate.value!)),
                  onPressed: () async {
                    HapticFeedback.selectionClick();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) selectedDate.value = picked;
                  },
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                )),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  HapticFeedback.vibrate();
                  onEdit(textController.text, selectedCategory.value, selectedPriority.value, selectedDate.value);
                  Get.back();
                },
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Update'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickCategory(BuildContext context, Rx<TodoCategory> selected) {
    Get.bottomSheet(
      _buildPickerSheet(
        context, 
        'Select Category', 
        TodoCategory.values.map((cat) => _buildPickerItem(cat.icon, cat.name.capitalizeFirst!, cat.color, () {
          HapticFeedback.selectionClick();
          selected.value = cat;
          Get.back();
        })).toList()
      ),
    );
  }

  void _pickPriority(BuildContext context, Rx<TodoPriority> selected) {
    Get.bottomSheet(
      _buildPickerSheet(
        context, 
        'Select Priority', 
        TodoPriority.values.map((prio) => _buildPickerItem(prio.icon, prio.name.capitalizeFirst!, prio.color, () {
          HapticFeedback.selectionClick();
          selected.value = prio;
          Get.back();
        })).toList()
      ),
    );
  }

  Widget _buildPickerSheet(BuildContext context, String title, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Wrap(spacing: 12, runSpacing: 12, children: items),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPickerItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
