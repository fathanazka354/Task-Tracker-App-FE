import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/task_entity.dart';

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final isDone = status == TaskStatus.done;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: isDone
            ? AppTheme.successColor.withOpacity(0.12)
            : AppTheme.pendingColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDone ? AppTheme.successColor : AppTheme.pendingColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? AppTheme.successColor : AppTheme.pendingColor,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isDone ? 'Done' : 'Pending',
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w600,
              color: isDone ? AppTheme.successColor : AppTheme.pendingColor,
            ),
          ),
        ],
      ),
    );
  }
}
