import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/components/bottom_navbar.dart';
import 'package:teamtasks/components/workspace_swapper.dart';
import 'package:teamtasks/screens/home/home_screen.dart';
import 'package:teamtasks/screens/home/workspace_settings.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';
import 'package:go_router/go_router.dart';
import '../../components/app_drawer.dart';
import '../../nav_prov.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: ref.read(navIndexProvider));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isCurrentWorkspaceAdminProvider);

    ref.listen(navIndexProvider, (previous, next) {
      if (_pageController.hasClients) {
        // If not admin and trying to go to settings tab (index 3), prevent it
        if (!isAdmin && next >= 3) {
          ref.read(navIndexProvider.notifier).setIndex(0);
          return;
        }

        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutQuad,
        );
      }
    });

    // If suddenly not admin but on settings tab, move to home
    ref.listen(isCurrentWorkspaceAdminProvider, (previous, next) {
      if (!next && ref.read(navIndexProvider) >= 3) {
        ref.read(navIndexProvider.notifier).setIndex(0);
      }
    });

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      backgroundColor: Colors.grey.shade200,
      bottomNavigationBar: const BottomNavbar(),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        actions: [_buildNotificationStack()],
        backgroundColor: Colors.grey.shade200,
        shadowColor: Colors.grey.shade50,
        elevation: 1,
        leadingWidth: 50,
        leading: Builder(
          builder: (context) {
            return IconButton(
              padding: const EdgeInsets.all(8),
              icon: Icon(Icons.menu_rounded, color: Colors.grey.shade600),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
        title: const WorkspaceSwapper(),
      ),
      drawer: const AppDrawer(),
      // PageView allows for the smooth sliding transition between bodies
      body: PageView(
        controller: _pageController,
        physics:
            const NeverScrollableScrollPhysics(), // Prevents accidental swiping
        children: [
          const HomeScreen(),
          const HomeScreen(),
          const HomeScreen(),
          if (isAdmin) const WorkspaceSettings(),
        ],
      ),
    );
  }

  Widget _buildNotificationStack() {
    final pendingAssignmentsAsync = ref.watch(pendingAssignmentsProvider);

    return pendingAssignmentsAsync.when(
      data: (assignments) {
        final hasNotifications = assignments.isNotEmpty;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: Icon(
                hasNotifications
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                color: hasNotifications ? Colors.purple : Colors.grey.shade600,
              ),
              onPressed: () {
                context.push('/notifications');
              },
            ),
            if (hasNotifications)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
          ],
        );
      },
      loading: () => IconButton(
        icon: Icon(
          Icons.notifications_none_rounded,
          color: Colors.grey.shade600,
        ),
        onPressed: null,
      ),
      error: (_, __) => IconButton(
        icon: Icon(
          Icons.notifications_none_rounded,
          color: Colors.grey.shade600,
        ),
        onPressed: null,
      ),
    );
  }
}
