import 'package:equatable/equatable.dart';

enum TaskStatus { pending, done }

extension TaskStatusExtension on TaskStatus {
  String get value => name;

  static TaskStatus fromString(String value) {
    return TaskStatus.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => TaskStatus.pending,
    );
  }
}

class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDone => status == TaskStatus.done;

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    TaskStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, status, createdAt, updatedAt];
}

class PaginatedTasks extends Equatable {
  final List<TaskEntity> tasks;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  const PaginatedTasks({
    required this.tasks,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  bool get hasNextPage => page < totalPages;

  @override
  List<Object?> get props => [tasks, total, page, perPage, totalPages];
}
