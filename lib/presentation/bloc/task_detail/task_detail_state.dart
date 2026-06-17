import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';

abstract class TaskDetailState extends Equatable {
  const TaskDetailState();

  @override
  List<Object?> get props => [];
}

class TaskDetailInitial extends TaskDetailState {
  const TaskDetailInitial();
}

class TaskDetailLoading extends TaskDetailState {
  const TaskDetailLoading();
}

class TaskDetailLoaded extends TaskDetailState {
  final TaskEntity task;
  final bool isUpdating;

  const TaskDetailLoaded({required this.task, this.isUpdating = false});

  TaskDetailLoaded copyWith({TaskEntity? task, bool? isUpdating}) {
    return TaskDetailLoaded(
      task: task ?? this.task,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }

  @override
  List<Object?> get props => [task, isUpdating];
}

class TaskDetailError extends TaskDetailState {
  final String message;

  const TaskDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

class TaskStatusUpdateSuccess extends TaskDetailState {
  final TaskEntity task;

  const TaskStatusUpdateSuccess(this.task);

  @override
  List<Object?> get props => [task];
}
