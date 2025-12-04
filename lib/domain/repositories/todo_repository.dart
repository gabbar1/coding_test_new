import '../../core/utils/result.dart';
import '../entities/todo_entity.dart';

abstract class ITodoRepository {
  Future<Result<List<TodoEntity>>> getTodos();
  Future<Result<TodoEntity>> createTodo(String title);
  Future<Result<TodoEntity>> updateTodo(TodoEntity todo);
  Future<Result<void>> deleteTodo(int id);
  Future<Result<void>> syncPendingChanges();
  Future<Result<void>> clearLocalData();
}

