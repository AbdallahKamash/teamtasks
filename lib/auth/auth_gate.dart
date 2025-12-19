import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/auth/auth_prov.dart';
import 'package:teamtasks/screens/auth/auth_screen.dart';
import 'package:teamtasks/screens/auth/home_screen.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: authState.when(
          loading: () => const Text(""),
          error: (e, _) => Text(""),
          data: (user) {
            if (user == null) return const AuthScreen();
            return const HomeScreen();
          },
        ),
      ),
    );
  }
}
