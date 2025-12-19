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
                if (user != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.purple.shade100,
                              child: Text(
                                user.displayName.isNotEmpty
                                    ? user.displayName[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
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
                  SizedBox(height: 8,),
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
                    context.pop(); // Close drawer
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
        loading: () => const Center(child: CircularProgressIndicator()),
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
      color: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            showModalBottomSheet(
              context: context,
              enableDrag: false,
              isScrollControlled: false,
              backgroundColor: Colors.grey.shade200,
              constraints: const BoxConstraints(
                minHeight: 50,
                minWidth: double.infinity,
              ),
              scrollControlDisabledMaxHeightRatio: 0.2,
              sheetAnimationStyle: AnimationStyle(
                curve: Curves.easeInCubic,
                duration: Duration(milliseconds: 300),
                reverseCurve: Curves.easeOutCubic,
                reverseDuration: Duration(milliseconds: 200),
              ),
              builder: (context) {
                return Directionality(
                  textDirection: TextDirection.rtl,
                  child: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        automaticallyImplyLeading: false,
                        backgroundColor: Colors.grey.shade200,
                        elevation: 0,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'مساحات العمل',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '3',
                              style: TextStyle(
                                fontFamily: 'Alexandria',
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      SliverFillRemaining(
                        hasScrollBody: true,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: const [
                            Text('Item 1'),
                            Text('Item 2'),
                            Text('Item 3'),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('شسيشسي', style: TextStyle(fontFamily: 'Alexandria', fontSize: 13, fontWeight: .bold),),
              Icon(Icons.arrow_forward_ios_rounded, size: 12,)
            ],
          ),
        ),
      ),
    );
  }
}
