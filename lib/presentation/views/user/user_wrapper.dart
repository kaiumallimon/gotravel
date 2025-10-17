import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gotravel/presentation/views/user/pages/user_home_page_figma.dart';
import 'package:gotravel/presentation/views/user/pages/my_trip_page.dart';
import 'package:gotravel/presentation/views/user/pages/search_page.dart';
import 'package:gotravel/presentation/views/user/pages/ai_chat_page.dart';
import 'package:gotravel/presentation/views/user/pages/more_page.dart';

class UserWrapper extends StatefulWidget {
  const UserWrapper({super.key});

  @override
  State<UserWrapper> createState() => _UserWrapperState();
}

class _UserWrapperState extends State<UserWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const UserHomePageFigma(),
    const MyTripPage(),
    const SearchPage(),
    const AiChatPage(),
    const MorePage(),
  ];

  final List<NavigationDestination> _navigationDestinations = [
    const NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    const NavigationDestination(
      icon: Icon(Icons.card_travel_outlined),
      selectedIcon: Icon(Icons.card_travel),
      label: 'My Trip',
    ),
    const NavigationDestination(
      icon: Icon(Icons.search_outlined),
      selectedIcon: Icon(Icons.search),
      label: 'Search',
    ),
    const NavigationDestination(
      icon: Icon(Icons.smart_toy_outlined),
      selectedIcon: Icon(Icons.smart_toy),
      label: 'AI',
    ),
    const NavigationDestination(
      icon: Icon(Icons.menu_outlined),
      selectedIcon: Icon(Icons.menu),
      label: 'More',
    ),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.primary.withOpacity(0.1),
              width: 2,
            ),
          ),
        ),
        child: Theme(
          data: theme.copyWith(
            navigationBarTheme: NavigationBarThemeData(
              backgroundColor: Colors.white,
              indicatorColor: theme.colorScheme.primary.withOpacity(0.1),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return IconThemeData(color: theme.colorScheme.primary);
                }
                return IconThemeData(color: theme.colorScheme.onSurfaceVariant);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  );
                }
                return TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                );
              }),
            ),
          ),
          child: NavigationBar(
            
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: _navigationDestinations,
            elevation: 8,
            surfaceTintColor: Colors.transparent,
            animationDuration: const Duration(milliseconds: 300),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          ),
        ),
      ),
    );
  }

}