import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/todo_entity.dart';
import '../../../domain/repositories/todo_repository.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final ITodoRepository _repository;

  TodoBloc(this._repository) : super(const TodoInitial()) {
    on<LoadTodosEvent>(_onLoadTodos);
    on<RefreshTodosEvent>(_onRefreshTodos);
    on<CreateTodoEvent>(_onCreateTodo);
    on<UpdateTodoEvent>(_onUpdateTodo);
    on<DeleteTodoEvent>(_onDeleteTodo);
    on<SearchTodosEvent>(_onSearchTodos);
    on<SyncTodosEvent>(_onSyncTodos);
    on<ClearLocalDataEvent>(_onClearLocalData);
  }

  Future<void> _onLoadTodos(
    LoadTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    emit(const TodoLoading());
    final result = await _repository.getTodos();
    
    result.when(
      success: (todos) {
        emit(TodoLoaded(
          todos: todos,
          filteredTodos: todos,
        ));
      },
      error: (failure) {
        emit(TodoError(failure.message));
      },
    );
  }

  Future<void> _onRefreshTodos(
    RefreshTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    if (state is TodoLoaded) {
      final currentState = state as TodoLoaded;
      emit(currentState.copyWith());
    }
    
    await _repository.syncPendingChanges();
    final result = await _repository.getTodos();
    
    result.when(
      success: (todos) {
        final currentState = state;
        if (currentState is TodoLoaded) {
          final filtered = _filterTodos(todos, currentState.searchQuery);
          emit(TodoLoaded(
            todos: todos,
            filteredTodos: filtered,
            searchQuery: currentState.searchQuery,
          ));
        } else {
          emit(TodoLoaded(
            todos: todos,
            filteredTodos: todos,
          ));
        }
      },
      error: (failure) {
        if (state is TodoLoaded) {
          final currentState = state as TodoLoaded;
          emit(currentState);
        } else {
          emit(TodoError(failure.message));
        }
      },
    );
  }

  Future<void> _onCreateTodo(
    CreateTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final result = await _repository.createTodo(event.title);
    
    result.when(
      success: (todo) {
        final currentState = state;
        if (currentState is TodoLoaded) {
          final updatedTodos = [todo, ...currentState.todos];
          final filtered = _filterTodos(updatedTodos, currentState.searchQuery);
          emit(currentState.copyWith(
            todos: updatedTodos,
            filteredTodos: filtered,
          ));
        }
      },
      error: (failure) {
        emit(TodoError(failure.message));
      },
    );
  }

  Future<void> _onUpdateTodo(
    UpdateTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final result = await _repository.updateTodo(event.todo);
    
    result.when(
      success: (updatedTodo) {
        final currentState = state;
        if (currentState is TodoLoaded) {
          final updatedTodos = currentState.todos.map((t) {
            return t.id == updatedTodo.id ? updatedTodo : t;
          }).toList();
          final filtered = _filterTodos(updatedTodos, currentState.searchQuery);
          emit(currentState.copyWith(
            todos: updatedTodos,
            filteredTodos: filtered,
          ));
        }
      },
      error: (failure) {
        emit(TodoError(failure.message));
      },
    );
  }

  Future<void> _onDeleteTodo(
    DeleteTodoEvent event,
    Emitter<TodoState> emit,
  ) async {
    final result = await _repository.deleteTodo(event.id);
    
    result.when(
      success: (_) {
        final currentState = state;
        if (currentState is TodoLoaded) {
          final updatedTodos = currentState.todos.where((t) => t.id != event.id).toList();
          final filtered = _filterTodos(updatedTodos, currentState.searchQuery);
          emit(currentState.copyWith(
            todos: updatedTodos,
            filteredTodos: filtered,
          ));
        }
      },
      error: (failure) {
        emit(TodoError(failure.message));
      },
    );
  }

  void _onSearchTodos(
    SearchTodosEvent event,
    Emitter<TodoState> emit,
  ) {
    final currentState = state;
    if (currentState is TodoLoaded) {
      final filtered = _filterTodos(currentState.todos, event.query);
      emit(currentState.copyWith(
        filteredTodos: filtered,
        searchQuery: event.query,
      ));
    }
  }

  Future<void> _onSyncTodos(
    SyncTodosEvent event,
    Emitter<TodoState> emit,
  ) async {
    await _repository.syncPendingChanges();
    add(const LoadTodosEvent());
  }

  Future<void> _onClearLocalData(
    ClearLocalDataEvent event,
    Emitter<TodoState> emit,
  ) async {
    final result = await _repository.clearLocalData();
    result.when(
      success: (_) {
        add(const LoadTodosEvent());
      },
      error: (failure) {
        emit(TodoError(failure.message));
      },
    );
  }

  List<TodoEntity> _filterTodos(List<TodoEntity> todos, String query) {
    if (query.isEmpty) return todos;
    final lowerQuery = query.toLowerCase();
    return todos.where((todo) {
      return todo.title.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

