import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/components/workspace_button.dart';

import '../auth/auth_prov.dart';
import '../router/router.dart';


class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserDataProvider);
    final router = ref.read(routerProvider);
    return Drawer(
      child: userAsync.when(
        data: (user) => Container(
          color: Colors.grey.shade200,
          child: SafeArea(
            child: Column(
              children: [
                // 🔹 FIXED HEADER
                const SizedBox(height: 24),

                if (user != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          backgroundImage:
                          user.pfp != null && user.pfp!.isNotEmpty
                              ? NetworkImage(user.pfp!)
                              : null,
                          child: user.pfp == null || user.pfp!.isEmpty
                              ? Text(
                            user.displayName.isNotEmpty
                                ? user.displayName[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                style: const TextStyle(
                                  fontFamily: 'Alexandria',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                user.email,
                                style: TextStyle(
                                  fontFamily: 'Alexandria',
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔹 FIXED WORKSPACE BUTTON
                  const WorkspaceButton(),

                ],

                // 🔹 SCROLLABLE CONTENT
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: const [
                      ListTile(
                        leading: Icon(Icons.description_outlined),
                        title: Text('Page 1',
                            style: TextStyle(fontFamily: 'Alexandria')),
                      ),
                      ListTile(
                        leading: Icon(Icons.description_outlined),
                        title: Text('Page 2',
                            style: TextStyle(fontFamily: 'Alexandria')),
                      ),
                      ListTile(
                        leading: Icon(Icons.description_outlined),
                        title: Text('Page 3',
                            style: TextStyle(fontFamily: 'Alexandria')),
                      ),
                    ],
                  ),
                ),

                // 🔹 FIXED BOTTOM
                Divider(height: 1, color: Colors.grey.shade300,),

                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontFamily: 'Alexandria'),
                  ),
                  onTap: () {
                    router.push('/settings');
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        loading: () => Container(
          color: Colors.grey.shade200,
          child: const Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}