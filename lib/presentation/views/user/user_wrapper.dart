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

  final List<Map<String, dynamic>> _navigationItems = [
    {
      'icon': CupertinoIcons.house,
      'activeIcon': CupertinoIcons.house_fill,
      'label': 'Home',
    },
    {
      'icon': CupertinoIcons.bag,
      'activeIcon': CupertinoIcons.bag_fill,
      'label': 'My Trip',
    },
    {
      'icon': CupertinoIcons.search,
      'activeIcon': CupertinoIcons.search,
      'label': 'Search',
    },
    {
      'icon': CupertinoIcons.chat_bubble,
      'activeIcon': CupertinoIcons.chat_bubble_fill,
      'label': 'AI',
    },
    {
      'icon': CupertinoIcons.ellipsis,
      'activeIcon': CupertinoIcons.ellipsis_circle_fill,
      'label': 'More',
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                _navigationItems.length,
                (index) => _buildNavItem(
                  item: _navigationItems[index],
                  index: index,
                  isActive: _currentIndex == index,
                  theme: theme,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required Map<String, dynamic> item,
    required int index,
    required bool isActive,
    required ThemeData theme,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? item['activeIcon'] : item['icon'],
              color: isActive 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item['label'],
              style: theme.textTheme.bodySmall?.copyWith(
                color: isActive 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}