import 'package:flutter/material.dart';
// import 'package:running/pages/home_page.dart';
// import 'package:running/pages/profile_page.dart';

class MyNavigation extends StatefulWidget {
  const MyNavigation({super.key});

  @override
  State<MyNavigation> createState() => _MyNavigationState();
}

class _MyNavigationState extends State<MyNavigation> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (value) => setState(() {
        selectedIndex = value;
      }),
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home),
          label: "홈",
          selectedIcon: Icon(
            Icons.home,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
        NavigationDestination(
          icon: const Icon(Icons.account_circle),
          label: "마이페이지",
          selectedIcon: Icon(
            Icons.account_circle,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ],
    );
  }
}
