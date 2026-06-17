import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';

abstract class TaskDetailEvent extends Equatable {
  const TaskDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadTaskDetailEvent extends TaskDetailEvent {
  final String taskId;

  const LoadTaskDetailEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class ToggleTaskStatusEvent extends TaskDetailEvent {
  final String taskId;
  final TaskStatus currentStatus;

  const ToggleTaskStatusEvent({required this.taskId, required this.currentStatus});

  @override
  List<Object?> get props => [taskId, currentStatus];
}
