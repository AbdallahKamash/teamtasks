import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/components/bottom_navbar.dart';
import 'package:teamtasks/components/workspace_swapper.dart';
import 'package:teamtasks/screens/home/home_screen.dart';
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
    ref.listen(navIndexProvider, (previous, next) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutQuad,
        );
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
        children: const [
          HomeScreen(),
          HomeScreen(),
          HomeScreen(),
          HomeScreen(),
        ],
      ),
    );
  }

  Widget _buildNotificationStack() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_none_rounded,
            color: Colors.grey.shade600,
          ),
          onPressed: () {},
        ),
        const Positioned(
          top: 12,
          right: 12,
          child: CircleAvatar(backgroundColor: Colors.red, radius: 3),
        ),
      ],
    );
  }
}
