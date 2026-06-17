import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:task_tracker_app/domain/entities/task_entity.dart';
import 'package:task_tracker_app/domain/repositories/task_repository.dart';
import 'package:task_tracker_app/domain/usecases/get_tasks_usecase.dart';

import 'get_tasks_usecase_test.mocks.dart';

@GenerateMocks([TaskRepository])
void main() {
  late GetTasksUseCase useCase;
  late MockTaskRepository mockRepository;

  setUp(() {
    mockRepository = MockTaskRepository();
    useCase = GetTasksUseCase(mockRepository);
  });

  final tPaginatedTasks = PaginatedTasks(
    tasks: [
      TaskEntity(
        id: '1',
        title: 'Test Task',
        description: 'Test Description',
        status: TaskStatus.pending,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    ],
    total: 1,
    page: 1,
    perPage: 10,
    totalPages: 1,
  );

  group('GetTasksUseCase', () {
    test('should return paginated tasks from repository', () async {
      when(mockRepository.getTasks(page: 1, perPage: 10))
          .thenAnswer((_) async => tPaginatedTasks);

      final result = await useCase(const GetTasksParams(page: 1, perPage: 10));

      expect(result.tasks.length, 1);
      expect(result.tasks.first.title, 'Test Task');
      verify(mockRepository.getTasks(page: 1, perPage: 10));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should use default params when none provided', () async {
      when(mockRepository.getTasks(page: 1, perPage: 10))
          .thenAnswer((_) async => tPaginatedTasks);

      await useCase(const GetTasksParams());

      verify(mockRepository.getTasks(page: 1, perPage: 10));
    });

    test('should propagate exceptions from repository', () async {
      when(mockRepository.getTasks(page: 1, perPage: 10))
          .thenThrow(Exception('Server error'));

      expect(
        () async => await useCase(const GetTasksParams()),
        throwsA(isA<Exception>()),
      );
    });
  });
}
