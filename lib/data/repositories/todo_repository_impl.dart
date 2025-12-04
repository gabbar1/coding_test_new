import 'package:uuid/uuid.dart';
import '../../core/errors/failures.dart';
import '../../core/utils/network_info.dart';
import '../../core/utils/result.dart';
import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/local/todo_local_data_source.dart';
import '../models/pending_sync_model.dart';
import '../models/todo_model.dart';
import '../datasources/remote/todo_remote_data_source.dart';

class TodoRepositoryImpl implements ITodoRepository {
  final ITodoRemoteDataSource _remoteDataSource;
  final ITodoLocalDataSource _localDataSource;
  final INetworkInfo _networkInfo;
  final Uuid _uuid;

  TodoRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._uuid,
  );

  @override
  Future<Result<List<TodoEntity>>> getTodos() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      
      if (isConnected) {
        try {
          final remoteTodos = await _remoteDataSource.getTodos();
          await _localDataSource.cacheTodos(remoteTodos);
          return Success(remoteTodos.map<TodoEntity>((e) => e.toEntity()).toList());
        } catch (e) {
          final localTodos = await _localDataSource.getTodos();
          if (localTodos.isEmpty) {
            return Error(ServerFailure(e.toString()));
          }
          return Success(localTodos.map<TodoEntity>((e) => e.toEntity()).toList());
        }
      } else {
        final localTodos = await _localDataSource.getTodos();
        return Success(localTodos.map((e) => e.toEntity()).toList());
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<TodoEntity>> createTodo(String title) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      final localId = _uuid.v4();
      final tempId = DateTime.now().millisecondsSinceEpoch;
      
      final newTodo = TodoModel(
        id: tempId,
        userId: 1,
        title: title,
        completed: false,
        isLocal: true,
        localId: localId,
      );

      await _localDataSource.saveTodo(newTodo);

      if (isConnected) {
        try {
          final createdTodo = await _remoteDataSource.createTodo(
            TodoModel(
              id: 0,
              userId: 1,
              title: title,
              completed: false,
            ),
          );
          
          await _localDataSource.deleteTodo(tempId);
          await _localDataSource.saveTodo(createdTodo);
          
          return Success(createdTodo.toEntity());
        } catch (e) {
          await _localDataSource.savePendingSync(
            PendingSyncModel(
              id: localId,
              action: SyncAction.create,
              data: {'title': title},
            ),
          );
          return Success(newTodo.toEntity());
        }
      } else {
        await _localDataSource.savePendingSync(
          PendingSyncModel(
            id: localId,
            action: SyncAction.create,
            data: {'title': title},
          ),
        );
        return Success(newTodo.toEntity());
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<TodoEntity>> updateTodo(TodoEntity todo) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      final todoModel = TodoModel(
        id: todo.id,
        userId: todo.userId,
        title: todo.title,
        completed: todo.completed,
        isLocal: todo.isLocal,
        localId: todo.localId,
      );

      await _localDataSource.updateTodo(todoModel);

      if (isConnected) {
        try {
          final updatedTodo = await _remoteDataSource.updateTodo(todoModel);
          await _localDataSource.updateTodo(updatedTodo);
          return Success(updatedTodo.toEntity());
        } catch (e) {
          if (todo.localId != null) {
            await _localDataSource.savePendingSync(
              PendingSyncModel(
                id: todo.localId!,
                action: SyncAction.update,
                data: todoModel.toJson(),
                todoId: todo.id,
              ),
            );
          }
          return Success(todo);
        }
      } else {
        if (todo.localId != null) {
          await _localDataSource.savePendingSync(
            PendingSyncModel(
              id: todo.localId!,
              action: SyncAction.update,
              data: todoModel.toJson(),
              todoId: todo.id,
            ),
          );
        }
        return Success(todo);
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTodo(int id) async {
    try {
      final isConnected = await _networkInfo.isConnected;
      final todos = await _localDataSource.getTodos();
      final todo = todos.firstWhere(
        (t) => t.id == id,
        orElse: () => throw CacheFailure('Todo not found'),
      );

      await _localDataSource.deleteTodo(id);

      if (isConnected) {
        try {
          await _remoteDataSource.deleteTodo(id);
        } catch (e) {
          if (todo.localId != null) {
            await _localDataSource.savePendingSync(
              PendingSyncModel(
                id: todo.localId!,
                action: SyncAction.delete,
                todoId: id,
              ),
            );
          }
        }
      } else {
        if (todo.localId != null) {
          await _localDataSource.savePendingSync(
            PendingSyncModel(
              id: todo.localId!,
              action: SyncAction.delete,
              todoId: id,
            ),
          );
        }
      }
      return const Success(null);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> syncPendingChanges() async {
    try {
      final isConnected = await _networkInfo.isConnected;
      if (!isConnected) {
        return const Success(null);
      }

      final pendingSyncs = await _localDataSource.getPendingSyncs();
      
      for (final sync in pendingSyncs) {
        try {
          switch (sync.action) {
            case SyncAction.create:
              if (sync.data != null) {
                final created = await _remoteDataSource.createTodo(
                  TodoModel(
                    id: 0,
                    userId: 1,
                    title: sync.data!['title'] as String,
                    completed: false,
                  ),
                );
                await _localDataSource.saveTodo(created);
              }
              break;
            case SyncAction.update:
              if (sync.data != null && sync.todoId != null) {
                final todo = TodoModel.fromJson(sync.data!);
                await _remoteDataSource.updateTodo(todo);
                await _localDataSource.updateTodo(todo);
              }
              break;
            case SyncAction.delete:
              if (sync.todoId != null) {
                await _remoteDataSource.deleteTodo(sync.todoId!);
              }
              break;
          }
          await _localDataSource.deletePendingSync(sync.id);
        } catch (e) {
          continue;
        }
      }
      
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> clearLocalData() async {
    try {
      await _localDataSource.deleteAllTodos();
      return const Success(null);
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }
}

