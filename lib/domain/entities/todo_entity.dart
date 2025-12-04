import 'package:equatable/equatable.dart';

class TodoEntity extends Equatable {
  final int id;
  final int userId;
  final String title;
  final bool completed;
  final bool isLocal;
  final String? localId;

  const TodoEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
    this.isLocal = false,
    this.localId,
  });

  TodoEntity copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
    bool? isLocal,
    String? localId,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      isLocal: isLocal ?? this.isLocal,
      localId: localId ?? this.localId,
    );
  }

  @override
  List<Object?> get props => [id, userId, title, completed, isLocal, localId];
}

