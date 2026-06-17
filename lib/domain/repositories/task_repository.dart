import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<PaginatedTasks> getTasks({int page = 1, int perPage = 10});
  Future<TaskEntity> getTaskById(String id);
  Future<TaskEntity> createTask({required String title, required String description});
  Future<TaskEntity> updateTaskStatus({required String id, required TaskStatus status});
}
