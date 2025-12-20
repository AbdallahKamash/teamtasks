import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teamtasks/auth/auth_prov.dart';
import 'package:teamtasks/router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white70,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: null,
      ),
      drawer: AppDrawer(),
    );
  }
}

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final authRepo = ref.read(authRepoProvider);
    final userAsync = ref.watch(currentUserDataProvider);
    return Drawer(
      child: userAsync.when(
        data: (user) => Container(
          color: Colors.grey.shade200,
          child: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 10),
                if (user != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: .end,
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
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  WorkspaceButton(),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text(
                      'Page 1',
                      style: TextStyle(fontFamily: 'Alexandria'),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text(
                      'Page 2',
                      style: TextStyle(fontFamily: 'Alexandria'),
                    ),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: const Text(
                      'Page 3',
                      style: TextStyle(fontFamily: 'Alexandria'),
                    ),
                    onTap: () {},
                  ),
                ],
                const Spacer(),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text(
                    'Settings',
                    style: TextStyle(fontFamily: 'Alexandria'),
                  ),
                  onTap: () {
                    context.push('/settings');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.redAccent),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'Alexandria',
                      color: Colors.redAccent,
                    ),
                  ),
                  onTap: () async {
                    await authRepo.signOut();
                    ref.read(routerProvider).go('/');
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        loading: () => Container(
          color: Colors.grey.shade200,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class WorkspaceButton extends ConsumerStatefulWidget {
  const WorkspaceButton({super.key});

  @override
  ConsumerState<WorkspaceButton> createState() => _WorkspaceButtonState();
}

class _WorkspaceButtonState extends ConsumerState<WorkspaceButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                // Determine the max height based on the screen size and your 0.25 ratio
                final double maxHeight =
                    MediaQuery.of(context).size.height * 0.35;

                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: 100, // Your forced minimum
                      maxHeight: maxHeight, // Your forced maximum ratio
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize
                          .min, // Allows the column to shrink to content if below max
                      children: [
                        // Handle Bar Decoration
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Title Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: Row(
                            children: const [
                              Text(
                                'اختر مساحة العمل',
                                style: TextStyle(
                                  fontFamily: 'Alexandria',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(height: 0, color: Colors.grey.shade300),
                        // Scrollable List
                        Expanded(
                          child: ListView.separated(
                            itemCount: 14, // Example count
                            separatorBuilder: (context, index) =>
                                Divider(height: 0, color: Colors.grey.shade200),
                            itemBuilder: (context, index) {
                              return ListTile(
                                splashColor: Colors.transparent,
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${index + 1}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  'مساحة العمل ${index + 1}',
                                  style: const TextStyle(
                                    fontFamily: 'Alexandria',
                                    fontSize: 14,
                                  ),
                                ),
                                onTap: () => Navigator.pop(context),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'شسيشسي',
                style: TextStyle(
                  fontFamily: 'Alexandria',
                  fontSize: 13,
                  fontWeight: .bold,
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 12),
            ],
          ),
        ),
      ),
    );
  }
}
