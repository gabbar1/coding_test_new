import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/todo_entity.dart';
import '../bloc/todo/todo_bloc.dart';
import '../bloc/todo/todo_event.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoEntity todo;

  const TodoItemWidget({
    super.key,
    required this.todo,
  });

  void _toggleComplete(BuildContext context) {
    context.read<TodoBloc>().add(
      UpdateTodoEvent(
        todo.copyWith(completed: !todo.completed),
      ),
    );
  }

  void _deleteTodo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Todo'),
        content: const Text('Are you sure you want to delete this todo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TodoBloc>().add(DeleteTodoEvent(todo.id));
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (_) => _toggleComplete(context),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.completed
                ? TextDecoration.lineThrough
                : TextDecoration.none,
            color: todo.completed ? Colors.grey : null,
          ),
        ),
        subtitle: todo.isLocal
            ? Row(
                children: [
                  Icon(Icons.cloud_off, size: 14, color: Colors.orange[700]),
                  const SizedBox(width: 4),
                  Text(
                    'Pending sync',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              )
            : null,
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          color: Colors.red,
          onPressed: () => _deleteTodo(context),
        ),
      ),
    );
  }
}

