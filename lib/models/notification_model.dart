import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String userId;
  final String workspaceId;
  final String title;
  final String body;
  final String
  type; // task_assigned, task_submitted, task_approved, task_rejected
  final String? relatedId;
  final DateTime createdAt;
  final bool isRead;

  AppNotificationModel({
    required this.id,
    required this.userId,
    required this.workspaceId,
    required this.title,
    required this.body,
    required this.type,
    this.relatedId,
    required this.createdAt,
    this.isRead = false,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      workspaceId: json['workspaceId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? 'info',
      relatedId: json['relatedId'] as String?,
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
                DateTime.now(),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'workspaceId': workspaceId,
      'title': title,
      'body': body,
      'type': type,
      'relatedId': relatedId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
