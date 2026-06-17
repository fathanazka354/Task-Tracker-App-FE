import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:task_tracker_app/domain/entities/task_entity.dart';
import 'package:task_tracker_app/presentation/widgets/task_card.dart';

void main() {
  final pendingTask = TaskEntity(
    id: '1',
    title: 'Buy groceries',
    description: 'Milk, Eggs, Bread',
    status: TaskStatus.pending,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 1),
  );

  final doneTask = TaskEntity(
    id: '2',
    title: 'Finish report',
    description: 'Q4 sales report',
    status: TaskStatus.done,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
  );

  testWidgets('TaskCard shows title and description', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(task: pendingTask, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Buy groceries'), findsOneWidget);
    expect(find.text('Milk, Eggs, Bread'), findsOneWidget);
    expect(find.text('Pending'), findsOneWidget);
  });

  testWidgets('TaskCard shows Done status for done tasks', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(task: doneTask, onTap: () {}),
        ),
      ),
    );

    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('TaskCard calls onTap when tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskCard(task: pendingTask, onTap: () => tapped = true),
        ),
      ),
    );

    await tester.tap(find.byType(TaskCard));
    expect(tapped, isTrue);
  });
}
