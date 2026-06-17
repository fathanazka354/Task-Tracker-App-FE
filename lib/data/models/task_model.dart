import 'dart:convert';
import '../../domain/entities/task_entity.dart';

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    required super.description,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TaskStatusExtension.fromString(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromEntity(TaskEntity entity) {
    return TaskModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  static String encodeList(List<TaskModel> tasks) {
    return jsonEncode(tasks.map((t) => t.toJson()).toList());
  }

  static List<TaskModel> decodeList(String jsonStr) {
    final List<dynamic> decoded = jsonDecode(jsonStr);
    return decoded.map((item) => TaskModel.fromJson(item as Map<String, dynamic>)).toList();
  }
}
