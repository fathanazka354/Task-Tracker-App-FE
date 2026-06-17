import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/task_list/task_list_bloc.dart';
import '../bloc/task_list/task_list_event.dart';
import '../bloc/task_list/task_list_state.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/error_state_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/task_card.dart';
import 'add_task_page.dart';
import 'task_detail_page.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TaskListBloc>()..add(const LoadTasksEvent()),
      child: const _TaskListView(),
    );
  }
}

class _TaskListView extends StatefulWidget {
  const _TaskListView();

  @override
  State<_TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<_TaskListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TaskListBloc>().add(const LoadMoreTasksEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        title: const Text(
          'Task Tracker',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          BlocBuilder<TaskListBloc, TaskListState>(
            builder: (context, state) {
              if (state is TaskListLoaded && state.isFromCache) {
                return const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Chip(
                    label: Text('Cached', style: TextStyle(fontSize: 11)),
                    backgroundColor: Colors.orange,
                    labelStyle: TextStyle(color: Colors.white),
                    padding: EdgeInsets.zero,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskListBloc, TaskListState>(
        builder: (context, state) {
          if (state is TaskListLoading) {
            return const LoadingWidget(message: 'Loading tasks...');
          }

          if (state is TaskListError && state.cachedTasks.isEmpty) {
            return ErrorStateWidget(
              message: state.message,
              onRetry: () => context.read<TaskListBloc>().add(const LoadTasksEvent()),
            );
          }

          if (state is TaskListLoaded || state is TaskListError) {
            final tasks = state is TaskListLoaded
                ? state.tasks
                : (state as TaskListError).cachedTasks;
            final hasMore = state is TaskListLoaded ? state.hasMore : false;
            final isLoadingMore =
                state is TaskListLoaded ? state.isLoadingMore : false;

            if (tasks.isEmpty) {
              return EmptyStateWidget(
                title: 'No Tasks Yet',
                subtitle: 'Start by adding your first task',
                icon: Icons.task_outlined,
                onAction: () => _navigateToAddTask(context),
                actionLabel: 'Add Task',
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<TaskListBloc>().add(const RefreshTasksEvent());
                await Future.delayed(const Duration(milliseconds: 800));
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: tasks.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == tasks.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final task = tasks[index];
                  return TaskCard(
                    task: task,
                    onTap: () => _navigateToDetail(context, task.id),
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddTask(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Future<void> _navigateToDetail(BuildContext context, String taskId) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TaskDetailPage(taskId: taskId)),
    );
    if (updated == true && context.mounted) {
      context.read<TaskListBloc>().add(const RefreshTasksEvent());
    }
  }

  Future<void> _navigateToAddTask(BuildContext context) async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddTaskPage()),
    );
    if (added == true && context.mounted) {
      context.read<TaskListBloc>().add(const LoadTasksEvent());
    }
  }
}
