import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/components/workspace_swapper.dart';

import '../../components/app_drawer.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        surfaceTintColor: Colors.grey,
        actions: [
          const SizedBox(width: 56),
        ],
        backgroundColor: Colors.white.withValues(alpha: 0),
        elevation: 1,
        actionsPadding: EdgeInsets.all(0),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: Colors.grey.shade600),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: WorkspaceSwapper(),
      ),
      drawer: AppDrawer(),
      body: Container(
        color: Colors.red,
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
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
