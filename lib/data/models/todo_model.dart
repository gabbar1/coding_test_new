import '../../domain/entities/todo_entity.dart';

class TodoModel extends TodoEntity {
  const TodoModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.completed,
    super.isLocal,
    super.localId,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      completed: json['completed'] as bool,
      isLocal: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completed': completed,
    };
  }

  Map<String, dynamic> toDbJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'completed': completed ? 1 : 0,
      'isLocal': isLocal ? 1 : 0,
      'localId': localId,
    };
  }

  factory TodoModel.fromDbJson(Map<String, dynamic> json) {
    return TodoModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      completed: (json['completed'] as int) == 1,
      isLocal: (json['isLocal'] as int) == 1,
      localId: json['localId'] as String?,
    );
  }

  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      userId: userId,
      title: title,
      completed: completed,
      isLocal: isLocal,
      localId: localId,
    );
  }
}

