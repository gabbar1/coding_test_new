import 'package:equatable/equatable.dart';
import '../../../domain/entities/todo_entity.dart';

abstract class TodoState extends Equatable {
  const TodoState();

  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {
  const TodoInitial();
}

class TodoLoading extends TodoState {
  const TodoLoading();
}

class TodoLoaded extends TodoState {
  final List<TodoEntity> todos;
  final List<TodoEntity> filteredTodos;
  final String searchQuery;

  const TodoLoaded({
    required this.todos,
    required this.filteredTodos,
    this.searchQuery = '',
  });

  TodoLoaded copyWith({
    List<TodoEntity>? todos,
    List<TodoEntity>? filteredTodos,
    String? searchQuery,
  }) {
    return TodoLoaded(
      todos: todos ?? this.todos,
      filteredTodos: filteredTodos ?? this.filteredTodos,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [todos, filteredTodos, searchQuery];
}

class TodoError extends TodoState {
  final String message;
  const TodoError(this.message);

  @override
  List<Object?> get props => [message];
}

