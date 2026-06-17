import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class UpdateTaskStatusParams {
  final String id;
  final TaskStatus status;

  const UpdateTaskStatusParams({required this.id, required this.status});
}

class UpdateTaskStatusUseCase {
  final TaskRepository repository;

  UpdateTaskStatusUseCase(this.repository);

  Future<TaskEntity> call(UpdateTaskStatusParams params) {
    return repository.updateTaskStatus(id: params.id, status: params.status);
  }
}
