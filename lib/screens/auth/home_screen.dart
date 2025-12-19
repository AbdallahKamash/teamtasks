import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            ref.read(routerProvider).pop();
          },
          child: Text('data'),
        ),
      ),
    );
  }
}
