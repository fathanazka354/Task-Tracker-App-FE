import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../core/theme/app_theme.dart';
import '../bloc/add_task/add_task_bloc.dart';
import '../bloc/add_task/add_task_event.dart';
import '../bloc/add_task/add_task_state.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({super.key});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AddTaskBloc>(),
      child: BlocConsumer<AddTaskBloc, AddTaskState>(
        listener: (context, state) {
          if (state is AddTaskSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task created successfully!'),
                backgroundColor: AppTheme.successColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.of(context).pop(true);
          }
          if (state is AddTaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AddTaskLoading;
          return Scaffold(
            backgroundColor: AppTheme.surfaceColor,
            appBar: AppBar(title: const Text('Add New Task')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task Title',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _titleController,
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                hintText: 'Enter task title...',
                                prefixIcon: Icon(Icons.title),
                              ),
                              maxLength: 100,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Title is required';
                                }
                                if (value.trim().length < 3) {
                                  return 'Title must be at least 3 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Description',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descriptionController,
                              enabled: !isLoading,
                              decoration: const InputDecoration(
                                hintText: 'Describe the task in detail...',
                                prefixIcon: Icon(Icons.description_outlined),
                                alignLabelWithHint: true,
                              ),
                              maxLines: 5,
                              maxLength: 500,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Description is required';
                                }
                                if (value.trim().length < 5) {
                                  return 'Description must be at least 5 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : () => _onSubmit(context),
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add_task),
                        label: Text(isLoading ? 'Creating...' : 'Create Task'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AddTaskBloc>().add(
            SubmitAddTaskEvent(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
            ),
          );
    }
  }
}
