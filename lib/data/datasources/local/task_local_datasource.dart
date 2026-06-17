import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/task_model.dart';

abstract class TaskLocalDataSource {
  Future<List<TaskModel>> getCachedTasks();
  Future<void> cacheTasks(List<TaskModel> tasks);
  Future<bool> isCacheValid();
  Future<void> clearCache();
  Future<void> updateCachedTask(TaskModel task);
}

class TaskLocalDataSourceImpl implements TaskLocalDataSource {
  final SharedPreferences sharedPreferences;

  TaskLocalDataSourceImpl(this.sharedPreferences);

  @override
  Future<List<TaskModel>> getCachedTasks() async {
    final jsonStr = sharedPreferences.getString(AppConstants.cachedTasksKey);
    if (jsonStr == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonStr);
      return decoded
          .map((item) => TaskModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheTasks(List<TaskModel> tasks) async {
    final jsonStr = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await sharedPreferences.setString(AppConstants.cachedTasksKey, jsonStr);
    await sharedPreferences.setString(
      AppConstants.cacheTimestampKey,
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<bool> isCacheValid() async {
    final timestampStr = sharedPreferences.getString(AppConstants.cacheTimestampKey);
    if (timestampStr == null) return false;
    final cacheTime = DateTime.parse(timestampStr);
    final now = DateTime.now();
    return now.difference(cacheTime).inMinutes < AppConstants.cacheExpiryMinutes;
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(AppConstants.cachedTasksKey);
    await sharedPreferences.remove(AppConstants.cacheTimestampKey);
  }

  @override
  Future<void> updateCachedTask(TaskModel updatedTask) async {
    final tasks = await getCachedTasks();
    final updatedList = tasks.map((t) {
      return t.id == updatedTask.id ? updatedTask : t;
    }).toList();
    await cacheTasks(updatedList);
  }
}
