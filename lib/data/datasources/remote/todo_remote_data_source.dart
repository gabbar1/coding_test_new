import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/failures.dart';
import '../../models/todo_model.dart';

abstract class ITodoRemoteDataSource {
  Future<List<TodoModel>> getTodos();
  Future<TodoModel> createTodo(TodoModel todo);
  Future<TodoModel> updateTodo(TodoModel todo);
  Future<void> deleteTodo(int id);
}

class TodoRemoteDataSource implements ITodoRemoteDataSource {
  final Dio _dio;

  TodoRemoteDataSource(this._dio);

  @override
  Future<List<TodoModel>> getTodos() async {
    try {
      final response = await _dio.get('${ApiConstants.baseUrl}${ApiConstants.todosEndpoint}');
      final List<dynamic> data = response.data;
      return data.map((json) => TodoModel.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to fetch todos');
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<TodoModel> createTodo(TodoModel todo) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.todosEndpoint}',
        data: todo.toJson(),
      );
      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to create todo');
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<TodoModel> updateTodo(TodoModel todo) async {
    try {
      final response = await _dio.patch(
        '${ApiConstants.baseUrl}${ApiConstants.todosEndpoint}/${todo.id}',
        data: todo.toJson(),
      );
      return TodoModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to update todo');
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteTodo(int id) async {
    try {
      await _dio.delete('${ApiConstants.baseUrl}${ApiConstants.todosEndpoint}/$id');
    } on DioException catch (e) {
      throw ServerFailure(e.message ?? 'Failed to delete todo');
    } catch (e) {
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }
}

