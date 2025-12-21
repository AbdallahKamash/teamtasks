import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final workspacesAsync = ref.watch(workspacesProvider);
    final workspaces = workspacesAsync.asData?.value ?? [];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: workspaces.isEmpty
            ? Center(
                child: Text(
                  'لا يوجد مساحة عمل \n قم بإضافة مساحة عمل جديدة من الاعلى',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: 'Alexandria',
                  ),
                ),
              )
            : Text('sadas'),
      ),
    );
  }
}
