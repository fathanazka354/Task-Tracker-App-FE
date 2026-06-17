import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../domain/entities/task_entity.dart';
import '../bloc/task_detail/task_detail_bloc.dart';
import '../bloc/task_detail/task_detail_event.dart';
import '../bloc/task_detail/task_detail_state.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/status_badge.dart';

class TaskDetailPage extends StatelessWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskDetailBloc>()..add(LoadTaskDetailEvent(taskId)),
      child: const _TaskDetailView(),
    );
  }
}

class _TaskDetailView extends StatelessWidget {
  const _TaskDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskDetailBloc, TaskDetailState>(
      listener: (context, state) {
        if (state is TaskStatusUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Task marked as ${state.task.isDone ? "Done" : "Pending"}',
              ),
              backgroundColor:
                  state.task.isDone ? AppTheme.successColor : AppTheme.pendingColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Reload detail after status update
          context.read<TaskDetailBloc>().add(LoadTaskDetailEvent(state.task.id));
          Navigator.of(context).pop(true);
        }
      },
      builder: (context, state) {
        if (state is TaskDetailLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Detail')),
            body: const LoadingWidget(message: 'Loading task...'),
          );
        }

        if (state is TaskDetailError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Detail')),
            body: ErrorStateWidget(
              message: state.message,
              onRetry: () => context
                  .read<TaskDetailBloc>()
                  .add(LoadTaskDetailEvent(state.message)),
            ),
          );
        }

        if (state is TaskDetailLoaded) {
          return _buildDetailScaffold(context, state.task, state.isUpdating);
        }

        return Scaffold(appBar: AppBar(title: const Text('Task Detail')));
      },
    );
  }

  Widget _buildDetailScaffold(BuildContext context, TaskEntity task, bool isUpdating) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text('Task Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  decoration:
                                      task.isDone ? TextDecoration.lineThrough : null,
                                  color: task.isDone ? Colors.grey : null,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        StatusBadge(status: task.status),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      task.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: 'Created',
                      value: DateFormatter.format(task.createdAt),
                    ),
                    const SizedBox(height: 10),
                    _buildInfoRow(
                      context,
                      icon: Icons.update,
                      label: 'Last Updated',
                      value: DateFormatter.format(task.updatedAt),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUpdating
                    ? null
                    : () {
                        context.read<TaskDetailBloc>().add(
                              ToggleTaskStatusEvent(
                                taskId: task.id,
                                currentStatus: task.status,
                              ),
                            );
                      },
                icon: isUpdating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(task.isDone ? Icons.undo : Icons.check_circle_outline),
                label: Text(
                  isUpdating
                      ? 'Updating...'
                      : task.isDone
                          ? 'Mark as Pending'
                          : 'Mark as Done',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      task.isDone ? AppTheme.pendingColor : AppTheme.successColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[400]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
              fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}
