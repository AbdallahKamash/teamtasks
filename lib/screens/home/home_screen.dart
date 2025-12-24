import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/workspace/workspace_prov.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            : Text(
          selectedWorkspace.name,
          style: const TextStyle(
            fontFamily: 'Alexandria',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}