import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksParams {
  final int page;
  final int perPage;

  const GetTasksParams({this.page = 1, this.perPage = 10});
}

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<PaginatedTasks> call(GetTasksParams params) {
    return repository.getTasks(page: params.page, perPage: params.perPage);
  }
}
