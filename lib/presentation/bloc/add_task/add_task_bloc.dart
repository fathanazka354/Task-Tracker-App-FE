import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/create_task_usecase.dart';
import 'add_task_event.dart';
import 'add_task_state.dart';

class AddTaskBloc extends Bloc<AddTaskEvent, AddTaskState> {
  final CreateTaskUseCase createTaskUseCase;

  AddTaskBloc({required this.createTaskUseCase}) : super(const AddTaskInitial()) {
    on<SubmitAddTaskEvent>(_onSubmit);
    on<ResetAddTaskEvent>(_onReset);
  }

  Future<void> _onSubmit(SubmitAddTaskEvent event, Emitter<AddTaskState> emit) async {
    emit(const AddTaskLoading());
    try {
      final task = await createTaskUseCase(
        CreateTaskParams(title: event.title, description: event.description),
      );
      emit(AddTaskSuccess(task));
    } catch (e) {
      emit(AddTaskError(e.toString()));
    }
  }

  void _onReset(ResetAddTaskEvent event, Emitter<AddTaskState> emit) {
    emit(const AddTaskInitial());
  }
}
