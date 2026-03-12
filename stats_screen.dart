import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/todo_controller.dart';
import 'widgets/stat_card.dart';

class StatsScreen extends StatelessWidget {
  final TodoController controller = Get.find<TodoController>();

  StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Obx(() => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverallProgress(theme),
            const SizedBox(height: 32),
            _buildStatGrid(theme),
            const SizedBox(height: 32),
            _buildCategoryTable(theme),
            const SizedBox(height: 32),
            _buildPriorityTable(theme),
          ],
        ),
      )),
    );
  }

  Widget _buildOverallProgress(ThemeData theme) {
    final progress = controller.progressPercentage;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overall Progress',
                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: theme.textTheme.headlineSmall?.copyWith(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: theme.colorScheme.onPrimary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.onPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${controller.completedCount} of ${controller.totalCount} tasks completed',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(ThemeData theme) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Active',
          value: controller.activeCount.toString(),
          icon: Icons.pending_actions_rounded,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Done',
          value: controller.completedCount.toString(),
          icon: Icons.check_circle_outline_rounded,
          color: Colors.green,
        ),
      ],
    );
  }

  Widget _buildCategoryTable(ThemeData theme) {
    final stats = controller.categoryStats;
    return _buildSectionTable(
      theme, 
      'Tasks by Category', 
      stats.entries.map((e) => _TableRowData(e.key.name.capitalizeFirst!, e.value, e.key.color, e.key.icon)).toList(),
    );
  }

  Widget _buildPriorityTable(ThemeData theme) {
    final stats = controller.priorityStats;
    return _buildSectionTable(
      theme, 
      'Tasks by Priority', 
      stats.entries.map((e) => _TableRowData(e.key.name.capitalizeFirst!, e.value, e.key.color, e.key.icon)).toList(),
    );
  }

  Widget _buildSectionTable(ThemeData theme, String title, List<_TableRowData> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(3),
              1: FlexColumnWidth(1),
            },
            children: [
              ...rows.map((row) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(row.icon, size: 18, color: row.color),
                        const SizedBox(width: 12),
                        Text(row.label, style: const TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      row.value.toString(),
                      textAlign: TextAlign.end,
                      style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              )),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableRowData {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  _TableRowData(this.label, this.value, this.color, this.icon);
}
