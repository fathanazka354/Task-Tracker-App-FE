import 'package:equatable/equatable.dart';
import '../../../domain/entities/task_entity.dart';

abstract class AddTaskState extends Equatable {
  const AddTaskState();

  @override
  List<Object?> get props => [];
}

class AddTaskInitial extends AddTaskState {
  const AddTaskInitial();
}

class AddTaskLoading extends AddTaskState {
  const AddTaskLoading();
}

class AddTaskSuccess extends AddTaskState {
  final TaskEntity task;

  const AddTaskSuccess(this.task);

  @override
  List<Object?> get props => [task];
}

class AddTaskError extends AddTaskState {
  final String message;

  const AddTaskError(this.message);

  @override
  List<Object?> get props => [message];
}
