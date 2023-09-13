// import 'package:flutter/material.dart';
// import 'package:running/pages/home_page.dart';
// import 'package:running/pages/profile_page.dart';

// class MyNavigation extends StatefulWidget {
//   const MyNavigation({super.key});

//   @override
//   State<MyNavigation> createState() => _MyNavigationState();
// }

// class _MyNavigationState extends State<MyNavigation> {
//   int _selectedIndex = 0;

//   final List<Widget> _widgetOptions = <Widget>[
//     const MyHomePage(),
//     const MyProfilePage(),
//   ];

//   void _onItemTap(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: _widgetOptions.elementAt(_selectedIndex),
//       ),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: "홈",
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.account_circle),
//             label: "마이페이지",
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         onTap: _onItemTap,
//       ),
//     );
//   }
// }
