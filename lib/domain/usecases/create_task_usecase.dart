import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTaskParams {
  final String title;
  final String description;

  const CreateTaskParams({required this.title, required this.description});
}

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<TaskEntity> call(CreateTaskParams params) {
    return repository.createTask(
      title: params.title,
      description: params.description,
    );
  }
}
