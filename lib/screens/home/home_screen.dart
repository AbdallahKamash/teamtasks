import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';
import '../../models/task_model.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_prov.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Color _getPriorityColor(String type) {
    switch (type) {
      case 'very_urgent':
        return Colors.red.shade600;
      case 'urgent':
        return Colors.orange.shade600;
      case 'suggestion':
        return Colors.blue.shade400;
      default:
        return Colors.grey.shade500;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'assigned':
        return 'مُعينة';
      case 'submitted_for_review':
        return 'قيد المراجعة';
      case 'completed':
        return 'منتهية';
      case 'rejected':
        return 'مرفوضة';
      default:
        return status;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'very_urgent':
        return 'عاجلة جداً';
      case 'urgent':
        return 'عاجلة';
      case 'suggestion':
        return 'اقتراح';
      default:
        return 'عادية';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedWorkspace = ref.watch(selectedWorkspaceProvider);
    final currentUser = ref.read(authRepoProvider).currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: selectedWorkspace == null
            ? Center(
                child: Text(
                  'لا يوجد مساحة عمل\nقم بإضافة مساحة عمل جديدة من الأعلى',
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontFamily: 'Alexandria',
                    fontSize: 14,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'مهامي',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedWorkspace.name,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (currentUser != null)
                    Expanded(
                      child: StreamBuilder<List<TaskModel>>(
                        stream: ref.read(workspaceRepoProvider).getAssignedTasksStream(selectedWorkspace.id, currentUser.uid),
                        builder: (context, snap) {
                          if (snap.connectionState == ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: Colors.purple.shade400,
                              ),
                            );
                          }
                          final tasks = snap.data ?? [];

                          // sort by importance type
                          int priority(String type) {
                            switch (type) {
                              case 'very_urgent':
                                return 4;
                              case 'urgent':
                                return 3;
                              case 'suggestion':
                                return 1;
                              default:
                                return 2;
                            }
                          }

                          tasks.sort((a, b) => priority(b.type).compareTo(priority(a.type)));

                          if (tasks.isEmpty) {
                            return Center(
                              child: Text(
                                'لا توجد مهام مخصصة لك',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  fontFamily: 'Alexandria',
                                  color: Colors.grey.shade500,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            itemCount: tasks.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, idx) {
                              final t = tasks[idx];
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    )
                                  ],
                                  border: Border(
                                    right: BorderSide(
                                      color: _getPriorityColor(t.type),
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      context.push('/task-detail', extra: t);
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            textDirection: TextDirection.rtl,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  t.title,
                                                  textDirection: TextDirection.rtl,
                                                  style: TextStyle(
                                                    fontFamily: 'Alexandria',
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: _getPriorityColor(t.type)
                                                      .withOpacity(0.15),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Text(
                                                  _getTypeLabel(t.type),
                                                  textDirection: TextDirection.rtl,
                                                  style: TextStyle(
                                                    fontFamily: 'Alexandria',
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w500,
                                                    color: _getPriorityColor(t.type),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            t.description,
                                            textDirection: TextDirection.rtl,
                                            style: TextStyle(
                                              fontFamily: 'Alexandria',
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 10),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.purple.shade50,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                _getStatusLabel(t.status),
                                                textDirection:
                                                    TextDirection.rtl,
                                                style: TextStyle(
                                                  fontFamily: 'Alexandria',
                                                  fontSize: 11,
                                                  color: Colors.purple.shade700,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}