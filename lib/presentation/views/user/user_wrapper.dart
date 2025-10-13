import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/presentation/views/user/pages/user_home_page.dart';
import 'package:gotravel/presentation/views/user/pages/user_packages_page.dart';
import 'package:gotravel/presentation/views/user/pages/user_profile_page.dart';

class UserWrapper extends StatefulWidget {
  const UserWrapper({super.key});

  @override
  State<UserWrapper> createState() => _UserWrapperState();
}

class _UserWrapperState extends State<UserWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const UserHomePage(),
    const UserPackagesPage(),
    const UserProfilePage(),
  ];

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': CupertinoIcons.house,
      'activeIcon': CupertinoIcons.house_fill,
      'label': 'Home',
    },
    {
      'icon': CupertinoIcons.cube_box,
      'activeIcon': CupertinoIcons.cube_box_fill,
      'label': 'Packages',
    },
    {
      'icon': CupertinoIcons.person,
      'activeIcon': CupertinoIcons.person_fill,
      'label': 'Profile',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: theme.colorScheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        elevation: 8,
        destinations: _navigationItems.map((item) {
          return NavigationDestination(
            icon: Icon(item['icon']),
            selectedIcon: Icon(item['activeIcon']),
            label: item['label'],
          );
        }).toList(),
      ),
    );
  }
}
