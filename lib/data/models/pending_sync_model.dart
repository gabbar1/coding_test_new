import 'dart:convert';

enum SyncAction { create, update, delete }

class PendingSyncModel {
  final String id;
  final SyncAction action;
  final Map<String, dynamic>? data;
  final int? todoId;

  const PendingSyncModel({
    required this.id,
    required this.action,
    this.data,
    this.todoId,
  });

  Map<String, dynamic> toDbJson() {
    return {
      'id': id,
      'action': action.name,
      'data': data != null ? jsonEncode(data) : null,
      'todoId': todoId,
    };
  }

  factory PendingSyncModel.fromDbJson(Map<String, dynamic> json) {
    return PendingSyncModel(
      id: json['id'] as String,
      action: SyncAction.values.firstWhere(
        (e) => e.name == json['action'],
      ),
      data: json['data'] != null
          ? jsonDecode(json['data'] as String) as Map<String, dynamic>
          : null,
      todoId: json['todoId'] as int?,
    );
  }
}

