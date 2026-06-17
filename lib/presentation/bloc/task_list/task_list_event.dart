import 'package:equatable/equatable.dart';

abstract class TaskListEvent extends Equatable {
  const TaskListEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasksEvent extends TaskListEvent {
  const LoadTasksEvent();
}

class LoadMoreTasksEvent extends TaskListEvent {
  const LoadMoreTasksEvent();
}

class RefreshTasksEvent extends TaskListEvent {
  const RefreshTasksEvent();
}

class TaskStatusUpdatedEvent extends TaskListEvent {
  final String taskId;
  final bool isDone;

  const TaskStatusUpdatedEvent({required this.taskId, required this.isDone});

  @override
  List<Object?> get props => [taskId, isDone];
}
