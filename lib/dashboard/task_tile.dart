import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'task_model.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(task.id),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Delete',
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? theme.colorScheme.primary.withOpacity(0.08)
                : theme.cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: task.isCompleted
                  ? theme.colorScheme.primary.withOpacity(0.3)
                  : Colors.transparent,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: GestureDetector(
              onTap: onToggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 26, height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: task.isCompleted ? theme.colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: task.isCompleted ? theme.colorScheme.primary : Colors.grey,
                    width: 2,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: theme.textTheme.bodyLarge!.copyWith(
                fontWeight: FontWeight.w600,
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                color: task.isCompleted ? Colors.grey : null,
              ),
              child: Text(task.title),
            ),
            subtitle: task.description != null
                ? Text(task.description!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey))
                : null,
            trailing: onEdit != null
                ? IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit)
                : null,
          ),
        ),
      ),
    );
  }
}