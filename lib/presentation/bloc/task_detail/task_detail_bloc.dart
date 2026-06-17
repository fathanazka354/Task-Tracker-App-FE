import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/task_entity.dart';
import '../../../domain/usecases/get_task_detail_usecase.dart';
import '../../../domain/usecases/update_task_status_usecase.dart';
import 'task_detail_event.dart';
import 'task_detail_state.dart';

class TaskDetailBloc extends Bloc<TaskDetailEvent, TaskDetailState> {
  final GetTaskDetailUseCase getTaskDetailUseCase;
  final UpdateTaskStatusUseCase updateTaskStatusUseCase;

  TaskDetailBloc({
    required this.getTaskDetailUseCase,
    required this.updateTaskStatusUseCase,
  }) : super(const TaskDetailInitial()) {
    on<LoadTaskDetailEvent>(_onLoad);
    on<ToggleTaskStatusEvent>(_onToggleStatus);
  }

  Future<void> _onLoad(LoadTaskDetailEvent event, Emitter<TaskDetailState> emit) async {
    emit(const TaskDetailLoading());
    try {
      final task = await getTaskDetailUseCase(event.taskId);
      emit(TaskDetailLoaded(task: task));
    } catch (e) {
      emit(TaskDetailError(e.toString()));
    }
  }

  Future<void> _onToggleStatus(
      ToggleTaskStatusEvent event, Emitter<TaskDetailState> emit) async {
    final currentState = state;
    if (currentState is! TaskDetailLoaded) return;

    emit(currentState.copyWith(isUpdating: true));

    final newStatus = event.currentStatus == TaskStatus.done
        ? TaskStatus.pending
        : TaskStatus.done;

    try {
      final updated = await updateTaskStatusUseCase(
        UpdateTaskStatusParams(id: event.taskId, status: newStatus),
      );
      emit(TaskStatusUpdateSuccess(updated));
    } catch (e) {
      emit(currentState.copyWith(isUpdating: false));
    }
  }
}
