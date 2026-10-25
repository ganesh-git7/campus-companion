import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import 'attendance_screen.dart';
import 'home_screen.dart';
import 'tasks_screen.dart';

/// Holds the Material 3 bottom navigation bar and the three main sections.
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.controller});

  final AppController controller;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    // Back button: from Attendance/Tasks go back to Home first;
    // from Home the system closes the app.
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(() => _index = 0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            HomeScreen(
              controller: widget.controller,
              onSeeAllTasks: () => setState(() => _index = 2),
            ),
            AttendanceScreen(controller: widget.controller),
            TasksScreen(controller: widget.controller),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.fact_check_outlined),
              selectedIcon: Icon(Icons.fact_check),
              label: 'Attendance',
            ),
            NavigationDestination(
              icon: Icon(Icons.checklist_outlined),
              selectedIcon: Icon(Icons.checklist),
              label: 'Tasks',
            ),
          ],
        ),
      ),
    );
  }
}
