class TaskModel {
  final String id;
  final String workspaceId;
  final String title;
  final String description;
  final String type; // normal, suggestion, urgent, very_urgent
  final String? assigneeId;
  final String creatorId;
  final String status; // assigned, submitted_for_review, under_review, completed, rejected
  final Map<String, dynamic>? meta; // for comments, reasons, history
  final DateTime createdAt;

  TaskModel({
    required this.id,
    required this.workspaceId,
    required this.title,
    required this.description,
    required this.type,
    required this.assigneeId,
    required this.creatorId,
    required this.status,
    required this.createdAt,
    this.meta,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      workspaceId: json['workspaceId'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? 'normal',
      assigneeId: json['assigneeId'] as String?,
      creatorId: json['creatorId'] as String? ?? '',
      status: json['status'] as String? ?? 'assigned',
      createdAt: (json['createdAt'] is DateTime)
          ? json['createdAt'] as DateTime
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      meta: json['meta'] is Map ? Map<String, dynamic>.from(json['meta']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workspaceId': workspaceId,
      'title': title,
      'description': description,
      'type': type,
      'assigneeId': assigneeId,
      'creatorId': creatorId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'meta': meta,
    };
  }

  TaskModel copyWith({
    String? id,
    String? workspaceId,
    String? title,
    String? description,
    String? type,
    String? assigneeId,
    String? creatorId,
    String? status,
    Map<String, dynamic>? meta,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      assigneeId: assigneeId ?? this.assigneeId,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      meta: meta ?? this.meta,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
