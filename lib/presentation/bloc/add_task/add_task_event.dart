import 'package:equatable/equatable.dart';

abstract class AddTaskEvent extends Equatable {
  const AddTaskEvent();

  @override
  List<Object?> get props => [];
}

class SubmitAddTaskEvent extends AddTaskEvent {
  final String title;
  final String description;

  const SubmitAddTaskEvent({required this.title, required this.description});

  @override
  List<Object?> get props => [title, description];
}

class ResetAddTaskEvent extends AddTaskEvent {
  const ResetAddTaskEvent();
}
