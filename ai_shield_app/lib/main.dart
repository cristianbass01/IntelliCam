import 'package:flutter/material.dart';
import 'package:ai_shield_app/settings/navigation.dart';
import 'package:ai_shield_app/settings/themes.dart';
import "package:provider/provider.dart";

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  NavigationHelper.instance;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const AIShieldApp(),
    ),
  );
}

class AIShieldApp extends StatelessWidget {
  const AIShieldApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    themeProvider.setSystemTheme(context, listen: false);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: NavigationHelper.router,
      theme: themeProvider.themeData,
    );
  }
}