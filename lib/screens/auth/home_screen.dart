import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/auth/auth_prov.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepo = ref.read(authRepoProvider);
    return Scaffold(
      body: Center(child: GestureDetector(
        onTap: () async {
          await authRepo.signOut();
        },
        child: Text('data'),
      )),
    );
  }
}
