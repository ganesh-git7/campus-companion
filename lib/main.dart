import 'package:flutter/material.dart';

import 'screens/main_shell.dart';
import 'services/app_controller.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved subjects and tasks before showing the first screen.
  final controller = AppController(StorageService());
  await controller.load();

  runApp(CampusCompanionApp(controller: controller));
}

class CampusCompanionApp extends StatelessWidget {
  const CampusCompanionApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Companion',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: MainShell(controller: controller),
    );
  }
}
