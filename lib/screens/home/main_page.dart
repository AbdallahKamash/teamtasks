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
  ConsumerState<MainPage> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<MainPage> {
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
    // This listener ensures the PageView slides when the BottomNavbar is tapped
    ref.listen(navIndexProvider, (previous, next) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutQuad, // Smooth, decelerating curve
        );
      }
    });

    return Scaffold(
      drawerEnableOpenDragGesture: false,
      backgroundColor: Colors.grey.shade200,
      bottomNavigationBar: const BottomNavbar(),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        actions: [
          _buildNotificationStack(),
        ],
        backgroundColor: Colors.grey.shade200,
        shadowColor: Colors.grey.shade50,
        elevation: 1,
        leadingWidth: 50,
        leading: Builder(builder: (context) {
          return IconButton(
            padding: EdgeInsets.all(8),
            icon: Icon(Icons.menu_rounded, color: Colors.grey.shade600),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
        title: const WorkspaceSwapper(),
      ),
      drawer: const AppDrawer(),
      // PageView allows for the smooth sliding transition between bodies
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Prevents accidental swiping
        children: [
          HomeScreen(),
          HomeScreen(),
          HomeScreen(),
          HomeScreen(),
        ],
      ),
    );
  }

  // Helper to keep the styling consistent with your original body
  Widget _buildPage(String title) {
    return Container(
      color: Colors.white24,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Center(child: Text(title, style: TextStyle(color: Colors.grey.shade800))),
        ),
      ),
    );
  }

  Widget _buildNotificationStack() {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.notifications_none_rounded, color: Colors.grey.shade600),
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