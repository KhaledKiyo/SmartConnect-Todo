import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/todo_controller.dart';
import '../../models/todo.dart';

class AddTaskSheet extends StatelessWidget {
  final TodoController controller;
  final TextEditingController textController;

  const AddTaskSheet({
    super.key,
    required this.controller,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
          Text('New Task', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: textController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'What are you planning?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Obx(() => ActionChip(
                avatar: Icon(controller.draftCategory.value.icon, size: 18),
                label: Text(controller.draftCategory.value.name.capitalizeFirst!),
                onPressed: () => _pickCategory(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )),
              Obx(() => ActionChip(
                avatar: Icon(controller.draftPriority.value.icon, size: 18, color: controller.draftPriority.value.color),
                label: Text(controller.draftPriority.value.name.capitalizeFirst!),
                onPressed: () => _pickPriority(context),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              )),
              Obx(() => ActionChip(
                avatar: const Icon(Icons.calendar_today_rounded, size: 18),
                label: Text(controller.draftDate.value == null
                    ? 'Set Date'
                    : DateFormat('MMM d').format(controller.draftDate.value!)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) controller.draftDate.value = picked;
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
                controller.addTodo(textController.text);
                Get.back();
              },
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }

  void _pickCategory(BuildContext context) {
    Get.bottomSheet(
      _buildPickerSheet(
        context, 
        'Select Category', 
        TodoCategory.values.map((cat) => _buildPickerItem(cat.icon, cat.name.capitalizeFirst!, cat.color, () {
          controller.draftCategory.value = cat;
          Get.back();
        })).toList()
      ),
    );
  }

  void _pickPriority(BuildContext context) {
    Get.bottomSheet(
      _buildPickerSheet(
        context, 
        'Select Priority', 
        TodoPriority.values.map((prio) => _buildPickerItem(prio.icon, prio.name.capitalizeFirst!, prio.color, () {
          controller.draftPriority.value = prio;
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
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
