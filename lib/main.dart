import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shaheen_namaz/utils/config/route_config.dart';
import 'firebase_options.dart';

void main() async {
  await dotenv.load(fileName: ".env");
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
      title: 'Shaheen Namaz App',
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff002147)),
          useMaterial3: true,
          listTileTheme: ListTileThemeData(
            textColor: Colors.white,
            selectedColor: Colors.white,
          )),
      routerConfig: routes,
    );
  }
}
