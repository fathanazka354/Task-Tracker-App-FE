import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/task_local_datasource.dart';
import '../../data/datasources/remote/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/get_task_detail_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/usecases/update_task_status_usecase.dart';
import '../../presentation/bloc/add_task/add_task_bloc.dart';
import '../../presentation/bloc/task_detail/task_detail_bloc.dart';
import '../../presentation/bloc/task_list/task_list_bloc.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  final apiClient = ApiClient();
  sl.registerLazySingleton<Dio>(() => apiClient.dio);

  // Data Sources
  sl.registerLazySingleton<TaskRemoteDataSource>(
    () => TaskRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSourceImpl(sl<SharedPreferences>()),
  );

  // Repository
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      remoteDataSource: sl<TaskRemoteDataSource>(),
      localDataSource: sl<TaskLocalDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetTasksUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => GetTaskDetailUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => CreateTaskUseCase(sl<TaskRepository>()));
  sl.registerLazySingleton(() => UpdateTaskStatusUseCase(sl<TaskRepository>()));

  // BLoCs (factory - new instance per page)
  sl.registerFactory(() => TaskListBloc(getTasksUseCase: sl<GetTasksUseCase>()));
  sl.registerFactory(
    () => TaskDetailBloc(
      getTaskDetailUseCase: sl<GetTaskDetailUseCase>(),
      updateTaskStatusUseCase: sl<UpdateTaskStatusUseCase>(),
    ),
  );
  sl.registerFactory(() => AddTaskBloc(createTaskUseCase: sl<CreateTaskUseCase>()));
}
