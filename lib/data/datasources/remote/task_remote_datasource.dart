import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../models/paginated_response_model.dart';
import '../../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<PaginatedResponseModel> getTasks({int page = 1, int perPage = 10});
  Future<TaskModel> getTaskById(String id);
  Future<TaskModel> createTask({required String title, required String description});
  Future<TaskModel> updateTaskStatus({required String id, required String status});
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final Dio dio;

  TaskRemoteDataSourceImpl(this.dio);

  @override
  Future<PaginatedResponseModel> getTasks({int page = 1, int perPage = 10}) async {
    try {
      final response = await dio.get(
        AppConstants.tasksEndpoint,
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final data = response.data as Map<String, dynamic>;
      return PaginatedResponseModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await dio.get('${AppConstants.tasksEndpoint}/$id');
      final data = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaskModel> createTask({required String title, required String description}) async {
    try {
      final response = await dio.post(
        AppConstants.tasksEndpoint,
        data: {'title': title, 'description': description},
      );
      final data = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<TaskModel> updateTaskStatus({required String id, required String status}) async {
    try {
      final response = await dio.patch(
        '${AppConstants.tasksEndpoint}/$id/status',
        data: {'status': status},
      );
      final data = response.data as Map<String, dynamic>;
      return TaskModel.fromJson(data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure();
    }
    if (e.response?.statusCode == 404) {
      return const NotFoundFailure('Task not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['error'] ?? 'Bad request';
      return ValidationFailure(message.toString());
    }
    return ServerFailure(e.message ?? 'Server error');
  }
}
