import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';
import 'package:go_router/go_router.dart';
import 'package:teamtasks/router/router.dart';

class WorkspaceSettings extends ConsumerWidget {
  const WorkspaceSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the currently selected workspace
    final selectedWorkspace = ref.watch(selectedWorkspaceProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: selectedWorkspace == null
            ? Center(
                child: Text(
                  'لا يوجد مساحة عمل \n قم بإضافة مساحة عمل جديدة من الأعلى',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: 'Alexandria',
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    // Logo or Initial
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _hexToColor(selectedWorkspace.color),
                        shape: BoxShape.circle,
                        image: selectedWorkspace.logoUrl != null
                            ? DecorationImage(
                                image: NetworkImage(selectedWorkspace.logoUrl!),
                                fit: BoxFit.cover,
                                onError: (_, _) {}, // Handle error silently
                              )
                            : null,
                      ),
                      child: selectedWorkspace.logoUrl == null
                          ? Center(
                              child: Text(
                                selectedWorkspace.name.isEmpty
                                    ? ''
                                    : selectedWorkspace.name[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Alexandria',
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(height: 24),
                    // Name
                    Text(
                      selectedWorkspace.name,
                      style: const TextStyle(
                        fontFamily: 'Alexandria',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (selectedWorkspace.description != null) ...[
                      const SizedBox(height: 12),
                      // Description
                      Text(
                        selectedWorkspace.description!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Alexandria',
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    const SizedBox(height: 48),
                    // Edit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to Edit Screen
                          context.push(
                            '/edit-workspace',
                            extra: selectedWorkspace,
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text(
                          'تعديل مساحة العمل',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            '/edit-workspace-scheme',
                            extra: selectedWorkspace,
                          );
                        },
                        icon: const Icon(Icons.account_tree),
                        label: const Text(
                          'تعديل الهيكل التنظيمي',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref
                              .read(routerProvider)
                              .push(
                                '/workspace-users',
                                extra: selectedWorkspace.id,
                              );
                        },
                        icon: const Icon(Icons.people_outline),
                        label: const Text(
                          'الأعضاء والصلاحيات',
                          style: TextStyle(
                            fontFamily: 'Alexandria',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.purple,
                          side: const BorderSide(color: Colors.purple),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Color _hexToColor(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}
