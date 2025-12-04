import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/errors/failures.dart';
import '../../models/pending_sync_model.dart';
import '../../models/todo_model.dart';

abstract class ITodoLocalDataSource {
  Future<List<TodoModel>> getTodos();
  Future<void> cacheTodos(List<TodoModel> todos);
  Future<TodoModel> saveTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
  Future<void> deleteAllTodos();
  Future<List<PendingSyncModel>> getPendingSyncs();
  Future<void> savePendingSync(PendingSyncModel sync);
  Future<void> deletePendingSync(String id);
}

class TodoLocalDataSource implements ITodoLocalDataSource {
  final SharedPreferences _prefs;

  TodoLocalDataSource(this._prefs);

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final todosJson = _prefs.getStringList(AppConstants.todosTable) ?? [];
      return todosJson
          .map((json) => TodoModel.fromDbJson(jsonDecode(json) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.id.compareTo(a.id));
    } catch (e) {
      throw CacheFailure('Failed to get todos from cache: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheTodos(List<TodoModel> todos) async {
    try {
      final todosJson = todos.map((todo) => jsonEncode(todo.toDbJson())).toList();
      await _prefs.setStringList(AppConstants.todosTable, todosJson);
    } catch (e) {
      throw CacheFailure('Failed to cache todos: ${e.toString()}');
    }
  }

  @override
  Future<TodoModel> saveTodo(TodoModel todo) async {
    try {
      final todos = await getTodos();
      todos.add(todo);
      await cacheTodos(todos);
      return todo;
    } catch (e) {
      throw CacheFailure('Failed to save todo: ${e.toString()}');
    }
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final todos = await getTodos();
      final index = todos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        todos[index] = todo;
        await cacheTodos(todos);
      }
      return todo;
    } catch (e) {
      throw CacheFailure('Failed to update todo: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      final todos = await getTodos();
      todos.removeWhere((t) => t.id == id);
      await cacheTodos(todos);
    } catch (e) {
      throw CacheFailure('Failed to delete todo: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAllTodos() async {
    try {
      await _prefs.remove(AppConstants.todosTable);
    } catch (e) {
      throw CacheFailure('Failed to delete all todos: ${e.toString()}');
    }
  }

  @override
  Future<List<PendingSyncModel>> getPendingSyncs() async {
    try {
      final syncsJson = _prefs.getStringList(AppConstants.pendingSyncTable) ?? [];
      return syncsJson
          .map((json) => PendingSyncModel.fromDbJson(jsonDecode(json) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheFailure('Failed to get pending syncs: ${e.toString()}');
    }
  }

  @override
  Future<void> savePendingSync(PendingSyncModel sync) async {
    try {
      final syncs = await getPendingSyncs();
      final existingIndex = syncs.indexWhere((s) => s.id == sync.id);
      if (existingIndex != -1) {
        syncs[existingIndex] = sync;
      } else {
        syncs.add(sync);
      }
      final syncsJson = syncs.map((s) => jsonEncode(s.toDbJson())).toList();
      await _prefs.setStringList(AppConstants.pendingSyncTable, syncsJson);
    } catch (e) {
      throw CacheFailure('Failed to save pending sync: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePendingSync(String id) async {
    try {
      final syncs = await getPendingSyncs();
      syncs.removeWhere((s) => s.id == id);
      final syncsJson = syncs.map((s) => jsonEncode(s.toDbJson())).toList();
      await _prefs.setStringList(AppConstants.pendingSyncTable, syncsJson);
    } catch (e) {
      throw CacheFailure('Failed to delete pending sync: ${e.toString()}');
    }
  }
}
