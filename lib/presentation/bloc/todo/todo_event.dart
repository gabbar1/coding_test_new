import 'package:equatable/equatable.dart';
import '../../../domain/entities/todo_entity.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosEvent extends TodoEvent {
  const LoadTodosEvent();
}

class RefreshTodosEvent extends TodoEvent {
  const RefreshTodosEvent();
}

class CreateTodoEvent extends TodoEvent {
  final String title;
  const CreateTodoEvent(this.title);

  @override
  List<Object?> get props => [title];
}

class UpdateTodoEvent extends TodoEvent {
  final TodoEntity todo;
  const UpdateTodoEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class DeleteTodoEvent extends TodoEvent {
  final int id;
  const DeleteTodoEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchTodosEvent extends TodoEvent {
  final String query;
  const SearchTodosEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SyncTodosEvent extends TodoEvent {
  const SyncTodosEvent();
}

class ClearLocalDataEvent extends TodoEvent {
  const ClearLocalDataEvent();
}

