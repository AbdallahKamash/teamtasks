import 'package:flutter/material.dart';
import 'package:teamtasks/components/workspace_swapper.dart';

import '../../components/app_drawer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        surfaceTintColor: Colors.grey,
        actions: [
          Stack(
            alignment: .center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.grey.shade600,
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(backgroundColor: Colors.red, radius: 3),
              ),
            ],
          ),
        ],
        backgroundColor: Colors.white.withValues(alpha: 0),
        elevation: 1,
        leadingWidth: 50,
        leading: Builder(builder: (context) {
          return IconButton(
            padding: EdgeInsets.all(0),
            icon: Icon(Icons.menu_rounded, color: Colors.grey.shade600),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
        title: WorkspaceSwapper(),
      ),
      drawer: AppDrawer(),
      body: Container(
        color: Colors.white24,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
