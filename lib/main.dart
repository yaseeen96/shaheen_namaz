import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shaheen_namaz/utils/config/route_config.dart';
import 'package:shaheen_namaz/utils/constants/constants.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'Ao Namaz Padhe',
      theme: ThemeData.dark().copyWith(
        primaryColor: Constants.primaryColor,
        primaryColorDark: Constants.primaryColor,
        scaffoldBackgroundColor: Constants.bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: Constants.secondaryColor,
      ),
      // ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff002147)),
      //   useMaterial3: true,
      //   listTileTheme: const ListTileThemeData(
      //     textColor: Colors.white,
      //     selectedColor: Colors.white,
      //   ),
      // ),
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
