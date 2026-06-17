import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';

abstract class TaskListState extends Equatable {
  const TaskListState();

  @override
  List<Object?> get props => [];
}

class TaskListInitial extends TaskListState {
  const TaskListInitial();
}

class TaskListLoading extends TaskListState {
  const TaskListLoading();
}

class TaskListLoaded extends TaskListState {
  final List<TaskEntity> tasks;
  final bool hasMore;
  final int currentPage;
  final bool isLoadingMore;
  final bool isFromCache;

  const TaskListLoaded({
    required this.tasks,
    required this.hasMore,
    required this.currentPage,
    this.isLoadingMore = false,
    this.isFromCache = false,
  });

  TaskListLoaded copyWith({
    List<TaskEntity>? tasks,
    bool? hasMore,
    int? currentPage,
    bool? isLoadingMore,
    bool? isFromCache,
  }) {
    return TaskListLoaded(
      tasks: tasks ?? this.tasks,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [tasks, hasMore, currentPage, isLoadingMore, isFromCache];
}

class TaskListError extends TaskListState {
  final String message;
  final List<TaskEntity> cachedTasks;

  const TaskListError({required this.message, this.cachedTasks = const []});

  @override
  List<Object?> get props => [message, cachedTasks];
}
