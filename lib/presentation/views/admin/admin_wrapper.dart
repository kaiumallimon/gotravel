import 'package:flutter/material.dart';
import 'package:gotravel/presentation/providers/admin_wrapper_provider.dart';
import 'package:provider/provider.dart';

class AdminWrapper extends StatelessWidget {
  const AdminWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final adminWrapperProvider = Provider.of<AdminWrapperProvider>(context);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: adminWrapperProvider.tabs.length,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _customAppBar(theme, adminWrapperProvider),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabBarDelegate(
                    TabBar(
                      tabAlignment: TabAlignment.start,
                      isScrollable: true,
                      physics: const BouncingScrollPhysics(),
                      labelColor: theme.colorScheme.primary,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                      unselectedLabelColor: theme.textTheme.bodyLarge?.color,
                      indicatorColor: theme.colorScheme.primary,
                      dividerColor: theme.colorScheme.primary.withAlpha(30),
                      tabs: adminWrapperProvider.tabs
                          .map((tab) => Tab(text: tab['title'] as String))
                          .toList(),
                    ),
                  ),
                ),
                SliverFillRemaining(
                  child: TabBarView(
                    children: adminWrapperProvider.tabs
                        .map((tab) => tab['child'] as Widget)
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SliverAppBar _customAppBar(
    ThemeData theme,
    AdminWrapperProvider adminWrapperProvider,
  ) {
    return SliverAppBar(
      floating: false,
      pinned: false,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 80,
      title: Text.rich(
        TextSpan(
          text: "Welcome\n",
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(.5)
          ),
          children: [
            TextSpan(
              text: adminWrapperProvider.accountData?.name ?? "Admin",
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
      centerTitle: false,
    );
  }
}

/// Custom delegate so the TabBar stays pinned under the appbar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _TabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
