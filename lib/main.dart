import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teamtasks/router/router.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Force dark status bar icons/text
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark, // Android
    statusBarBrightness: Brightness.dark,   // iOS
  ));

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      title: 'Animated Riverpod Routing',
      theme: ThemeData(useMaterial3: true,
        // This removes the splash/ripple effect globally
        splashFactory: NoSplash.splashFactory,
        // This removes the grey highlight that appears on tap/hold
        highlightColor: Colors.transparent,
        // Optional: removes the hover color (useful for Web/Desktop)
        hoverColor: Colors.transparent,
        // Optional: ensures buttons specifically don't show an overlay
        splashColor: Colors.transparent,
      ),
    );
  }
}