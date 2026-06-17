import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTaskDetailUseCase {
  final TaskRepository repository;

  GetTaskDetailUseCase(this.repository);

  Future<TaskEntity> call(String id) {
    return repository.getTaskById(id);
  }
}
