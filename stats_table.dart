import 'package:flutter/material.dart';

class StatsTable extends StatelessWidget {
  final String title;
  final List<StatsRowData> rows;

  const StatsTable({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            children: rows.map((row) => TableRow(
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
            )).toList(),
          ),
        ),
      ],
    );
  }
}

class StatsRowData {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  StatsRowData(this.label, this.value, this.color, this.icon);
}
