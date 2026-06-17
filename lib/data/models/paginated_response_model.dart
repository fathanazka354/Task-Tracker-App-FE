import '../../domain/entities/task_entity.dart';
import 'task_model.dart';

class PaginatedResponseModel {
  final List<TaskModel> data;
  final int total;
  final int page;
  final int perPage;
  final int totalPages;

  const PaginatedResponseModel({
    required this.data,
    required this.total,
    required this.page,
    required this.perPage,
    required this.totalPages,
  });

  factory PaginatedResponseModel.fromJson(Map<String, dynamic> json) {
    return PaginatedResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      perPage: json['per_page'] as int,
      totalPages: json['total_pages'] as int,
    );
  }

  PaginatedTasks toEntity() {
    return PaginatedTasks(
      tasks: data,
      total: total,
      page: page,
      perPage: perPage,
      totalPages: totalPages,
    );
  }
}
