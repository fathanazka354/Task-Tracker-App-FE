import '../../core/errors/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/task_local_datasource.dart';
import '../datasources/remote/task_remote_datasource.dart';
import '../models/task_model.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;
  final TaskLocalDataSource localDataSource;

  TaskRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<PaginatedTasks> getTasks({int page = 1, int perPage = 10}) async {
    try {
      final result = await remoteDataSource.getTasks(page: page, perPage: perPage);
      // Cache first page results
      if (page == 1) {
        await localDataSource.cacheTasks(result.data);
      }
      return result.toEntity();
    } catch (e) {
      if (e is NetworkFailure) {
        // Return cached data on network failure
        final cached = await localDataSource.getCachedTasks();
        if (cached.isNotEmpty) {
          return PaginatedTasks(
            tasks: cached,
            total: cached.length,
            page: 1,
            perPage: cached.length,
            totalPages: 1,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<TaskEntity> getTaskById(String id) async {
    return remoteDataSource.getTaskById(id);
  }

  @override
  Future<TaskEntity> createTask({required String title, required String description}) async {
    final task = await remoteDataSource.createTask(title: title, description: description);
    await localDataSource.clearCache();
    return task;
  }

  @override
  Future<TaskEntity> updateTaskStatus({required String id, required TaskStatus status}) async {
    final task = await remoteDataSource.updateTaskStatus(id: id, status: status.value);
    await localDataSource.updateCachedTask(TaskModel.fromEntity(task));
    return task;
  }
}
