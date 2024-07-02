import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shaheen_namaz/utils/config/route_config.dart';
import 'package:upgrader/upgrader.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ao Namaz Padhe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff002147)),
        useMaterial3: true,
        listTileTheme: const ListTileThemeData(
          textColor: Colors.white,
          selectedColor: Colors.white,
        ),
      ),
      routerConfig: routes,
      builder: (context, child) {
        return UpgradeAlert(
          navigatorKey: routes.routerDelegate.navigatorKey,
          child: child ?? const SizedBox(),
        );
      },
    );
  }
}
