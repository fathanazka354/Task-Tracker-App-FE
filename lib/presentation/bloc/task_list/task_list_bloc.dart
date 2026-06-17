import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/get_tasks_usecase.dart';
import 'task_list_event.dart';
import 'task_list_state.dart';

class TaskListBloc extends Bloc<TaskListEvent, TaskListState> {
  final GetTasksUseCase getTasksUseCase;

  TaskListBloc({required this.getTasksUseCase}) : super(const TaskListInitial()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<LoadMoreTasksEvent>(_onLoadMore);
    on<RefreshTasksEvent>(_onRefresh);
    on<TaskStatusUpdatedEvent>(_onTaskStatusUpdated);
  }

  Future<void> _onLoadTasks(LoadTasksEvent event, Emitter<TaskListState> emit) async {
    emit(const TaskListLoading());
    try {
      final result = await getTasksUseCase(
        const GetTasksParams(page: 1, perPage: AppConstants.defaultPerPage),
      );
      emit(TaskListLoaded(
        tasks: result.tasks,
        hasMore: result.hasNextPage,
        currentPage: result.page,
        isFromCache: false,
      ));
    } catch (e) {
      if (e is NetworkFailure) {
        emit(const TaskListError(message: 'No internet. Showing cached data.'));
      } else {
        emit(TaskListError(message: e.toString()));
      }
    }
  }

  Future<void> _onLoadMore(LoadMoreTasksEvent event, Emitter<TaskListState> emit) async {
    final currentState = state;
    if (currentState is! TaskListLoaded || currentState.isLoadingMore) return;
    if (!currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    try {
      final nextPage = currentState.currentPage + 1;
      final result = await getTasksUseCase(
        GetTasksParams(page: nextPage, perPage: AppConstants.defaultPerPage),
      );
      emit(TaskListLoaded(
        tasks: [...currentState.tasks, ...result.tasks],
        hasMore: result.hasNextPage,
        currentPage: result.page,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onRefresh(RefreshTasksEvent event, Emitter<TaskListState> emit) async {
    try {
      final result = await getTasksUseCase(
        const GetTasksParams(page: 1, perPage: AppConstants.defaultPerPage),
      );
      emit(TaskListLoaded(
        tasks: result.tasks,
        hasMore: result.hasNextPage,
        currentPage: result.page,
      ));
    } catch (e) {
      // Keep current state on refresh failure
    }
  }

  Future<void> _onTaskStatusUpdated(
      TaskStatusUpdatedEvent event, Emitter<TaskListState> emit) async {
    final currentState = state;
    if (currentState is! TaskListLoaded) return;

    final updatedTasks = currentState.tasks.map((task) {
      if (task.id == event.taskId) {
        return task.copyWith(
          status: event.isDone ? TaskStatus.done : TaskStatus.pending,
        );
      }
      return task;
    }).toList();

    emit(currentState.copyWith(tasks: updatedTasks));
  }
}
